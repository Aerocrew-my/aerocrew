import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/payment.dart';
import 'payment_repository.dart';

typedef PaymentTokenProvider = Future<String?> Function(bool refresh);

class PaymentException implements Exception {
  const PaymentException(
    this.message, {
    this.statusCode,
    this.refreshRequired = false,
  });
  final String message;
  final int? statusCode;
  final bool refreshRequired;
  @override
  String toString() => message;
}

class ApiPaymentRepository implements PaymentRepository {
  ApiPaymentRepository({
    FirebaseAuth? auth,
    http.Client? client,
    PaymentTokenProvider? tokenProvider,
    String? baseUrl,
  }) : _auth = auth ?? (tokenProvider == null ? FirebaseAuth.instance : null),
       _client = client ?? http.Client(),
       _tokenProvider = tokenProvider,
       _baseUrl =
           baseUrl ?? const String.fromEnvironment('ROSTER_EXTRACTION_URL');
  final FirebaseAuth? _auth;
  final http.Client _client;
  final PaymentTokenProvider? _tokenProvider;
  final String _baseUrl;
  Uri _uri(String suffix) {
    if (_baseUrl.trim().isEmpty) {
      throw const PaymentException(
        'Payments are not configured for this build.',
      );
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$base/v1/crew/payments$suffix');
  }

  Future<Map<String, String>> _headers([bool refresh = false]) async {
    final token =
        await (_tokenProvider?.call(refresh) ??
            _auth?.currentUser?.getIdToken(refresh));
    if (token == null || token.isEmpty) {
      throw const PaymentException(
        'Sign in to manage payment.',
        statusCode: 401,
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String>) call,
  ) async {
    var value = await call(
      await _headers(),
    ).timeout(const Duration(seconds: 30));
    if (value.statusCode == 401) {
      value = await call(
        await _headers(true),
      ).timeout(const Duration(seconds: 30));
    }
    return value;
  }

  Map<String, dynamic> _body(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const FormatException();
    return Map<String, dynamic>.from(decoded);
  }

  CrewPayment _payment(http.Response response, {required int expected}) {
    final body = _body(response);
    if (response.statusCode != expected) {
      throw PaymentException(
        switch (response.statusCode) {
          401 => 'Your session expired. Sign in again.',
          403 => 'You cannot access this payment.',
          409 => 'Payment changed on the server. Refreshing its status.',
          >= 500 => 'The payment service is unavailable.',
          _ => 'Payment could not be updated.',
        },
        statusCode: response.statusCode,
        refreshRequired: response.statusCode == 409,
      );
    }
    final value = body['payment'];
    if (value is! Map) throw const FormatException();
    return CrewPayment.fromMap(Map<String, dynamic>.from(value));
  }

  @override
  Future<CrewPayment> createForTrip(String tripId) async => _payment(
    await _send(
      (h) => _client.post(
        _uri(''),
        headers: h,
        body: jsonEncode({'tripId': tripId}),
      ),
    ),
    expected: 201,
  );
  @override
  Future<CrewPayment> getPayment(String paymentId) async => _payment(
    await _send(
      (h) =>
          _client.get(_uri('/${Uri.encodeComponent(paymentId)}'), headers: h),
    ),
    expected: 200,
  );
  @override
  Future<CrewPayment> completeTestPayment(String paymentId) async => _payment(
    await _send(
      (h) => _client.post(
        _uri('/${Uri.encodeComponent(paymentId)}/test-complete'),
        headers: h,
      ),
    ),
    expected: 200,
  );
}
