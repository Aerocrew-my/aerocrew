import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/trip_receipt.dart';
import 'receipt_repository.dart';

class ApiReceiptRepository implements ReceiptRepository {
  ApiReceiptRepository({
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
  Future<TripReceipt> getReceipt(String tripId) async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) throw StateError('Sign in to view this receipt.');
    if (_baseUrl.isEmpty) {
      throw StateError('Receipts are not configured for this build.');
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final response = await _client.get(
      Uri.parse('$base/v1/crew/trips/${Uri.encodeComponent(tripId)}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw StateError(
        response.statusCode >= 500
            ? 'Receipt service is unavailable.'
            : 'Receipt could not be loaded.',
      );
    }
    final body = jsonDecode(response.body);
    final trip = body is Map ? body['trip'] : null;
    if (trip is! Map) {
      throw const FormatException('Malformed receipt response.');
    }
    return TripReceipt.fromTripResponse(Map<String, dynamic>.from(trip));
  }
}
