import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/operator_earning.dart';
import 'operator_earnings_repository.dart';

class ApiOperatorEarningsRepository implements OperatorEarningsRepository {
  ApiOperatorEarningsRepository({
    FirebaseAuth? auth,
    http.Client? client,
    String? baseUrl,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _client = client ?? http.Client(),
       _baseUrl =
           baseUrl ?? const String.fromEnvironment('ROSTER_EXTRACTION_URL');
  final FirebaseAuth _auth;
  final http.Client _client;
  final String _baseUrl;
  @override
  Future<List<OperatorEarning>> getEarnings() async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) throw StateError('Sign in to view earnings.');
    if (_baseUrl.isEmpty) {
      throw StateError('Earnings are not configured for this build.');
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final response = await _client.get(
      Uri.parse('$base/v1/operator/earnings'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw StateError(
        response.statusCode >= 500
            ? 'Earnings are temporarily unavailable.'
            : 'Earnings could not be loaded.',
      );
    }
    final body = jsonDecode(response.body);
    final values = body is Map ? body['earnings'] : null;
    if (values is! List) {
      throw const FormatException('Malformed earnings response.');
    }
    return values
        .whereType<Map>()
        .map((v) => OperatorEarning.fromMap(Map<String, dynamic>.from(v)))
        .toList(growable: false);
  }
}
