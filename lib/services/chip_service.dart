import 'dart:convert';
import 'package:aerocrew/config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Payment commands go through a trusted backend; CHIP credentials and paid
/// status are never controlled by the Flutter client.
class ChipService {
  static Future<Map<String, dynamic>> createPurchase({
    required String email,
    required String name,
    required String phone,
    required double amount,
    required String description,
    required String reference,
  }) async {
    if (AppConfig.paymentApiUrl.isEmpty)
      return {
        'success': false,
        'error': 'Payments are not configured for this build.',
      };
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null)
      return {'success': false, 'error': 'Sign in before making a payment.'};
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.paymentApiUrl}/purchases'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'phone': phone,
          'amount': amount,
          'currency': 'MYR',
          'description': description,
          'reference': reference,
        }),
      );
      final data = response.body.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      if (response.statusCode >= 200 && response.statusCode < 300)
        return {'success': true, ...data};
      return {
        'success': false,
        'error': data['message'] ?? 'Payment creation failed',
      };
    } catch (_) {
      return {'success': false, 'error': 'The payment service is unavailable.'};
    }
  }

  static Future<Map<String, dynamic>> getPurchaseStatus(
    String purchaseId,
  ) async {
    if (AppConfig.paymentApiUrl.isEmpty)
      return {
        'success': false,
        'error': 'Payments are not configured for this build.',
      };
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null)
      return {'success': false, 'error': 'Sign in to check this payment.'};
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.paymentApiUrl}/purchases/$purchaseId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = response.body.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return response.statusCode == 200
          ? {'success': true, ...data}
          : {'success': false, 'error': 'Failed to get status'};
    } catch (_) {
      return {'success': false, 'error': 'The payment service is unavailable.'};
    }
  }

  static double getPriceForZone(String zone) {
    for (final entry in AppConfig.zonePricing.entries) {
      if (zone.toLowerCase().contains(entry.key.toLowerCase()))
        return entry.value;
    }
    return 750;
  }
}
