import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

typedef RosterTokenProvider = Future<String?> Function(bool forceRefresh);

class ApiRosterRepository implements RosterRepository {
  ApiRosterRepository({
    FirebaseAuth? auth,
    http.Client? client,
    RosterTokenProvider? tokenProvider,
    String? baseUrl,
    this.pollingInterval = const Duration(seconds: 2),
  }) : _auth = auth ?? (tokenProvider == null ? FirebaseAuth.instance : null),
       _client = client ?? http.Client(),
       _tokenProvider = tokenProvider,
       _baseUrl = baseUrl ?? _configuredBaseUrl;

  static const _configuredBaseUrl = String.fromEnvironment(
    'ROSTER_EXTRACTION_URL',
  );
  static const _timeout = Duration(seconds: 30);
  final FirebaseAuth? _auth;
  final http.Client _client;
  final RosterTokenProvider? _tokenProvider;
  final String _baseUrl;
  final Duration pollingInterval;

  Uri _uri([String suffix = '']) {
    if (_baseUrl.trim().isEmpty) {
      throw const RosterRepositoryException(
        'Secure roster processing is not configured for this build.',
      );
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$base/v1/roster-jobs$suffix');
  }

  Future<Map<String, String>> _headers({bool forceRefresh = false}) async {
    final token =
        await (_tokenProvider?.call(forceRefresh) ??
            _auth?.currentUser?.getIdToken(forceRefresh));
    if (token == null || token.isEmpty) {
      throw const RosterRepositoryException(
        'Sign in before uploading a roster.',
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    var response = await request(await _headers()).timeout(_timeout);
    if (response.statusCode == 401) {
      response = await request(
        await _headers(forceRefresh: true),
      ).timeout(_timeout);
    }
    return response;
  }

  @override
  Future<String> createRosterJob({
    required Uint8List bytes,
    required String mediaType,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw const RosterRepositoryException('The selected file is empty.');
    }
    try {
      final response = await _send(
        (headers) => _client.post(
          _uri(),
          headers: headers,
          body: jsonEncode({
            'mediaType': mediaType,
            'fileName': fileName,
            'file': base64Encode(bytes),
          }),
        ),
      );
      final body = _object(response.body);
      final jobId = body['jobId']?.toString();
      if (response.statusCode != 202 || jobId == null || jobId.isEmpty) {
        throw _error(response, body, 'The roster job could not be queued.');
      }
      return jobId;
    } on TimeoutException {
      throw const RosterRepositoryException(
        'Roster upload timed out. Try again.',
      );
    } on FormatException {
      throw const RosterRepositoryException(
        'The roster service returned malformed data.',
      );
    }
  }

  @override
  Future<Roster> getRoster(String rosterId) async {
    try {
      final response = await _send(
        (headers) => _client.get(_uri('/$rosterId'), headers: headers),
      );
      final body = _object(response.body);
      if (response.statusCode != 200) {
        throw _error(response, body, 'The roster could not be loaded.');
      }
      return Roster.fromMap(body['jobId']?.toString() ?? rosterId, body);
    } on TimeoutException {
      throw const RosterRepositoryException(
        'Roster status timed out. Try again.',
      );
    } on FormatException {
      throw const RosterRepositoryException(
        'The roster service returned malformed data.',
      );
    }
  }

  @override
  Stream<Roster> watchRoster(String rosterId) async* {
    while (true) {
      final roster = await getRoster(rosterId);
      yield roster;
      if (roster.status == RosterStatus.needsReview ||
          roster.status.isTerminal) {
        return;
      }
      await Future<void>.delayed(pollingInterval);
    }
  }

  @override
  Future<Roster> confirmRoster(String rosterId, List<RosterDuty> duties) async {
    try {
      final response = await _send(
        (headers) => _client.post(
          _uri('/$rosterId/confirm'),
          headers: headers,
          body: jsonEncode({
            'duties': duties
                .where((duty) => duty.confirmed)
                .map((duty) => duty.toConfirmationMap())
                .toList(),
          }),
        ),
      );
      final body = _object(response.body);
      if (response.statusCode != 200) {
        throw _error(response, body, 'The roster could not be confirmed.');
      }
      final roster = Roster.fromMap(
        body['jobId']?.toString() ?? rosterId,
        body,
      );
      if (roster.status != RosterStatus.confirmed) {
        throw const RosterRepositoryException(
          'The server did not confirm the roster. Check its status and retry.',
        );
      }
      return roster;
    } on TimeoutException {
      throw const RosterRepositoryException(
        'Roster confirmation timed out. Check its status before retrying.',
      );
    } on FormatException {
      throw const RosterRepositoryException(
        'The roster service returned malformed data.',
      );
    }
  }

  @override
  Future<void> retryRoster(String rosterId) async {
    final response = await _send(
      (headers) => _client.post(_uri('/$rosterId/retry'), headers: headers),
    );
    if (response.statusCode != 202) {
      final body = _object(response.body);
      throw _error(response, body, 'The roster job could not be retried.');
    }
  }

  Map<String, dynamic> _object(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw const FormatException();
    return Map<String, dynamic>.from(decoded);
  }

  RosterRepositoryException _error(
    http.Response response,
    Map<String, dynamic> body,
    String fallback,
  ) {
    final nested = body['error'];
    final errors = body['errors'];
    final value =
        body['message'] ??
        (nested is Map ? nested['message'] : nested) ??
        (errors is List && errors.isNotEmpty ? errors.first : null);
    final message = value is Map
        ? value['message']?.toString()
        : value?.toString();
    final statusFallback = switch (response.statusCode) {
      401 => 'Your session expired. Sign in again and retry.',
      403 => 'You do not have access to this roster.',
      409 => 'The roster changed on the server. Reload it and retry.',
      422 => 'The roster data could not be validated. Review the duties.',
      >= 500 => 'The roster service is unavailable. Try again later.',
      _ => fallback,
    };
    return RosterRepositoryException(
      message?.trim().isNotEmpty == true ? message! : statusFallback,
      statusCode: response.statusCode,
      code:
          body['code']?.toString() ??
          (nested is Map ? nested['code']?.toString() : null),
    );
  }
}
