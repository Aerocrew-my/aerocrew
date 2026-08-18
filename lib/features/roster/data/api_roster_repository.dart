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

  Uri _uri(String resource, [String suffix = '']) {
    if (_baseUrl.trim().isEmpty) {
      throw const RosterRepositoryException(
        'Secure roster processing is not configured for this build.',
      );
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$base/v1/$resource$suffix');
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
  Future<RosterUploadAuthorization> authorizeRosterUpload({
    required String fileName,
    required String mediaType,
  }) async {
    try {
      final response = await _send(
        (headers) => _client.post(
          _uri('roster-uploads'),
          headers: headers,
          body: jsonEncode({'mediaType': mediaType, 'fileName': fileName}),
        ),
      );
      final body = _object(response.body);
      if (response.statusCode != 201) {
        throw _error(response, body, 'Upload authorization failed. Try again.');
      }
      final uploadId = body['uploadId']?.toString() ?? '';
      final uploadUrl = Uri.tryParse(body['uploadUrl']?.toString() ?? '');
      final method = body['method']?.toString() ?? '';
      final expiresAt = DateTime.tryParse(body['expiresAt']?.toString() ?? '');
      final rawHeaders = body['headers'];
      if (uploadId.isEmpty ||
          uploadUrl == null ||
          !uploadUrl.hasScheme ||
          method.isEmpty ||
          expiresAt == null ||
          rawHeaders is! Map) {
        throw const FormatException();
      }
      return RosterUploadAuthorization(
        uploadId: uploadId,
        uploadUrl: uploadUrl,
        method: method,
        headers: rawHeaders.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
        expiresAt: expiresAt,
      );
    } on TimeoutException {
      throw const RosterRepositoryException(
        'Upload authorization timed out. Try again.',
      );
    } on FormatException {
      throw const RosterRepositoryException(
        'Upload authorization returned malformed data.',
      );
    }
  }

  @override
  Future<void> uploadRosterBytes(
    RosterUploadAuthorization authorization,
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty) {
      throw const RosterRepositoryException('The selected file is empty.');
    }
    try {
      final request =
          http.Request(authorization.method, authorization.uploadUrl)
            ..headers.addAll(authorization.headers)
            ..bodyBytes = bytes;
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final expired =
            authorization.expiresAt.isBefore(DateTime.now()) ||
            response.body.toLowerCase().contains('expired');
        throw RosterRepositoryException(
          expired
              ? 'The upload authorization expired. Preparing a new upload.'
              : 'Direct storage upload failed (${response.statusCode}). Try again.',
          statusCode: response.statusCode,
          code: expired
              ? 'upload_authorization_expired'
              : 'storage_upload_failed',
        );
      }
    } on TimeoutException {
      throw const RosterRepositoryException(
        'Direct storage upload timed out. Try again.',
        code: 'storage_upload_failed',
      );
    } on http.ClientException {
      throw const RosterRepositoryException(
        'Direct storage upload failed. On Flutter Web, verify the Storage bucket CORS allows this origin and PUT with the returned headers.',
        code: 'storage_upload_failed',
      );
    }
  }

  @override
  Future<String> createRosterJob({required String uploadId}) async {
    try {
      final response = await _send(
        (headers) => _client.post(
          _uri('roster-jobs'),
          headers: headers,
          body: jsonEncode({'uploadId': uploadId}),
        ),
      );
      final body = _object(response.body);
      final jobId = body['jobId']?.toString();
      if (response.statusCode != 202 || jobId == null || jobId.isEmpty) {
        throw _error(response, body, 'Job creation failed. Try again.');
      }
      return jobId;
    } on TimeoutException {
      throw const RosterRepositoryException(
        'Job creation timed out. Retry without uploading the file again.',
        code: 'job_creation_failed',
      );
    } on FormatException {
      throw const RosterRepositoryException(
        'Job creation returned malformed data.',
        code: 'job_creation_failed',
      );
    }
  }

  @override
  Future<Roster> getRoster(String rosterId) async {
    try {
      final response = await _send(
        (headers) =>
            _client.get(_uri('roster-jobs', '/$rosterId'), headers: headers),
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
          _uri('roster-jobs', '/$rosterId/confirm'),
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
      (headers) => _client.post(
        _uri('roster-jobs', '/$rosterId/retry'),
        headers: headers,
      ),
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
