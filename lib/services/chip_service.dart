import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aerocrew/config/app_config.dart';

class ChipService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.chipApiKey}',
  };

  /// Create a purchase/payment link for subscription
  static Future<Map<String, dynamic>> createPurchase({
    required String email,
    required String name,
    required String phone,
    required double amount,
    required String description,
    required String reference,
  }) async {
    if (AppConfig.chipApiKey.isEmpty) {
      return {
        'success': false,
        'error': 'Payments are not configured for this build.',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.chipBaseUrl}/purchases/'),
        headers: _headers,
        body: jsonEncode({
          'brand_id': AppConfig.chipBrandId,
          'client': {'email': email, 'full_name': name, 'phone': phone},
          'purchase': {
            'currency': 'MYR',
            'products': [
              {
                'name': description,
                'price': (amount * 100).toInt(), // CHIP uses cents
                'quantity': 1,
              },
            ],
          },
          'reference': reference,
          'success_redirect': '${AppConfig.appWebUrl}/payment-success',
          'failure_redirect': '${AppConfig.appWebUrl}/payment-failed',
          'cancel_redirect': '${AppConfig.appWebUrl}/payment-cancelled',
          'send_receipt': true,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'purchaseId': data['id'],
          'checkoutUrl': data['checkout_url'],
          'status': data['status'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Payment creation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get purchase status
  static Future<Map<String, dynamic>> getPurchaseStatus(
    String purchaseId,
  ) async {
    if (AppConfig.chipApiKey.isEmpty) {
      return {
        'success': false,
        'error': 'Payments are not configured for this build.',
      };
    }
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.chipBaseUrl}/purchases/$purchaseId/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'paid': data['status'] == 'paid',
        };
      }
      return {'success': false, 'error': 'Failed to get status'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Calculate price based on zone
  static double getPriceForZone(String zone) {
    for (final entry in AppConfig.zonePricing.entries) {
      if (zone.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return 750.0; // default
  }
}
