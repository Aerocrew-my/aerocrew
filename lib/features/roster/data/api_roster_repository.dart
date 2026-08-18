import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiRosterRepository implements RosterRepository {
  ApiRosterRepository({FirebaseAuth? auth, http.Client? client})
    : _auth = auth ?? FirebaseAuth.instance,
      _client = client ?? http.Client();

  static const _baseUrl = String.fromEnvironment('ROSTER_EXTRACTION_URL');
  static const _timeout = Duration(seconds: 30);
  final FirebaseAuth _auth;
  final http.Client _client;

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

  Future<Map<String, String>> _headers() async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) {
      throw const RosterRepositoryException(
        'Sign in before uploading a roster.',
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
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
      final response = await _client
          .post(
            _uri(),
            headers: await _headers(),
            body: jsonEncode({
              'mediaType': mediaType,
              'fileName': fileName,
              'file': base64Encode(bytes),
            }),
          )
          .timeout(_timeout);
      final body = _object(response.body);
      final jobId = body['jobId']?.toString();
      if (response.statusCode != 202 || jobId == null || jobId.isEmpty) {
        throw RosterRepositoryException(
          body['message']?.toString() ?? 'The roster job could not be queued.',
        );
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
      final response = await _client
          .get(_uri('/$rosterId'), headers: await _headers())
          .timeout(_timeout);
      final body = _object(response.body);
      if (response.statusCode != 200) {
        throw RosterRepositoryException(
          body['message']?.toString() ?? 'The roster could not be loaded.',
        );
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
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Future<Roster> confirmRoster(String rosterId, List<RosterDuty> duties) async {
    final response = await _client
        .post(
          _uri('/$rosterId/confirm'),
          headers: await _headers(),
          body: jsonEncode({
            'duties': duties
                .where((duty) => duty.confirmed)
                .map((duty) => duty.toMap(includeParserMetadata: false))
                .toList(),
          }),
        )
        .timeout(_timeout);
    final body = _object(response.body);
    if (response.statusCode != 200) {
      throw RosterRepositoryException(
        body['message']?.toString() ?? 'The roster could not be confirmed.',
      );
    }
    return Roster.fromMap(body['jobId']?.toString() ?? rosterId, body);
  }

  @override
  Future<void> retryRoster(String rosterId) async {
    final response = await _client
        .post(_uri('/$rosterId/retry'), headers: await _headers())
        .timeout(_timeout);
    if (response.statusCode != 202) {
      final body = _object(response.body);
      throw RosterRepositoryException(
        body['message']?.toString() ?? 'The roster job could not be retried.',
      );
    }
  }

  Map<String, dynamic> _object(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw const FormatException();
    return Map<String, dynamic>.from(decoded);
  }
}
