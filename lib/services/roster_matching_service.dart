import 'dart:convert';

import 'package:aerocrew/config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Requests transport-requirement generation and pool matching for a
/// confirmed duty from the trusted server, instead of performing pool
/// lookup/creation directly from the client.
///
/// Matching and pool creation are trusted-server responsibilities (see
/// handover section 7). Configure the endpoint at build time with
/// `--dart-define=ROSTER_MATCHING_URL=...`.
class RosterMatchingService {
  static Future<Map<String, dynamic>> matchCrewToPool({
    required String flightNumber,
    required DateTime flightDate,
    required String departureTime,
    required String airport,
    required String zone,
  }) async {
    if (!AppConfig.isRosterMatchingConfigured) {
      throw const MatchingNotConfiguredException(
        'Transport matching is not configured for this build.',
      );
    }
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      throw const MatchingNotConfiguredException(
        'Sign in before confirming a roster.',
      );
    }
    final dateStr =
        '${flightDate.year}-${flightDate.month.toString().padLeft(2, '0')}-${flightDate.day.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse('${AppConfig.rosterMatchingApiUrl}/match'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'flightNumber': flightNumber,
        'flightDate': dateStr,
        'departureTime': departureTime,
        'airport': airport,
        'zone': zone,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const MatchingNotConfiguredException(
        'The transport requirement could not be generated. It remains saved '
        'for server-side recovery.',
      );
    }

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    return decoded;
  }
}

class MatchingNotConfiguredException implements Exception {
  const MatchingNotConfiguredException(this.message);
  final String message;

  @override
  String toString() => message;
}
