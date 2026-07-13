import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Calls the server-side roster extraction endpoint.
///
/// API provider credentials must never ship in the Flutter application. Supply
/// the HTTPS endpoint at build time with `--dart-define=ROSTER_EXTRACTION_URL=...`.
class AnthropicService {
  static const _endpoint = String.fromEnvironment('ROSTER_EXTRACTION_URL');

  static bool get isConfigured => _endpoint.trim().isNotEmpty;

  static Future<List<Map<String, dynamic>>> extractRoster(
    Uint8List bytes,
    String mediaType,
  ) async {
    if (!isConfigured) {
      throw const RosterExtractionException(
        'Secure roster extraction is not configured for this build.',
      );
    }
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      throw const RosterExtractionException(
        'Sign in before uploading a roster.',
      );
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'mediaType': mediaType, 'file': base64Encode(bytes)}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const RosterExtractionException(
        'The roster could not be processed. Try again or contact support.',
      );
    }

    final decoded = jsonDecode(response.body);
    final duties = decoded is List ? decoded : (decoded as Map)['duties'];
    if (duties is! List) {
      throw const RosterExtractionException(
        'The extraction response was not in the expected format.',
      );
    }
    return duties
        .whereType<Map>()
        .map((duty) => Map<String, dynamic>.from(duty))
        .toList();
  }
}

class RosterExtractionException implements Exception {
  const RosterExtractionException(this.message);
  final String message;

  @override
  String toString() => message;
}
