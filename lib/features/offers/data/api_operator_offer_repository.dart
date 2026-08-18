import 'dart:async';
import 'dart:convert';

import 'package:aerocrew/features/offers/data/operator_offer_repository.dart';
import 'package:aerocrew/features/offers/domain/operator_offer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

typedef OfferTokenProvider = Future<String?> Function(bool forceRefresh);

class ApiOperatorOfferRepository implements OperatorOfferRepository {
  ApiOperatorOfferRepository({
    FirebaseAuth? auth,
    http.Client? client,
    OfferTokenProvider? tokenProvider,
    String? baseUrl,
    this.pollingInterval = const Duration(seconds: 30),
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
  final OfferTokenProvider? _tokenProvider;
  final String _baseUrl;
  final Duration pollingInterval;

  Uri _uri([String suffix = '']) {
    if (_baseUrl.trim().isEmpty) {
      throw const OperatorOfferException(
        'Operator dispatch is not configured for this build.',
      );
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$base/v1/operator/offers$suffix');
  }

  Future<Map<String, String>> _headers({bool forceRefresh = false}) async {
    final token =
        await (_tokenProvider?.call(forceRefresh) ??
            _auth?.currentUser?.getIdToken(forceRefresh));
    if (token == null || token.isEmpty) {
      throw const OperatorOfferException(
        'Your session expired. Sign in again.',
        code: 'UNAUTHENTICATED',
        statusCode: 401,
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String>) request,
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
  Future<List<OperatorOffer>> listOffers() async {
    try {
      final response = await _send(
        (headers) => _client.get(_uri(), headers: headers),
      );
      final body = _object(response.body);
      if (response.statusCode != 200) throw _error(response, body);
      final values = body['offers'];
      if (values is! List) throw const FormatException();
      return values
          .whereType<Map>()
          .map(
            (value) => OperatorOffer.fromMap(Map<String, dynamic>.from(value)),
          )
          .toList(growable: false);
    } on TimeoutException {
      throw const OperatorOfferException(
        'Offers timed out. Check your connection.',
      );
    } on FormatException {
      throw const OperatorOfferException(
        'The offer service returned malformed data.',
      );
    } on http.ClientException {
      throw const OperatorOfferException(
        'Offers are unavailable while offline.',
      );
    }
  }

  @override
  Stream<List<OperatorOffer>> watchOffers() async* {
    while (true) {
      yield await listOffers();
      await Future<void>.delayed(pollingInterval);
    }
  }

  @override
  Future<void> accept(String offerId, {required String vehicleId}) async {
    final response = await _action(offerId, 'accept', {'vehicleId': vehicleId});
    final body = _object(response.body);
    if (response.statusCode != 200) throw _error(response, body);
    if (body['status'] != 'accepted') {
      throw const OperatorOfferException(
        'The server did not confirm this assignment.',
      );
    }
  }

  @override
  Future<void> decline(String offerId, OfferDeclineReason reason) async {
    final response = await _action(offerId, 'decline', {'reason': reason.name});
    final body = _object(response.body);
    if (response.statusCode != 200) throw _error(response, body);
    if (body['status'] != 'declined') {
      throw const OperatorOfferException(
        'The server did not confirm this decline.',
      );
    }
  }

  Future<http.Response> _action(
    String offerId,
    String action,
    Map<String, dynamic> body,
  ) => _send(
    (headers) => _client.post(
      _uri('/${Uri.encodeComponent(offerId)}/$action'),
      headers: headers,
      body: jsonEncode(body),
    ),
  );

  Map<String, dynamic> _object(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map) throw const FormatException();
    return Map<String, dynamic>.from(decoded);
  }

  OperatorOfferException _error(
    http.Response response,
    Map<String, dynamic> body,
  ) {
    final nested = body['error'];
    final code =
        body['code']?.toString() ??
        (nested is Map ? nested['code']?.toString() : null);
    final message = switch (code) {
      'OFFER_EXPIRED' => 'This offer has expired.',
      'OFFER_NOT_PENDING' ||
      'ALREADY_ASSIGNED' => 'This offer was taken or is no longer available.',
      'VEHICLE_REQUIRED' => 'Select an eligible vehicle.',
      'INVALID_VEHICLE' => 'That vehicle is unavailable or not verified.',
      'INSUFFICIENT_CAPACITY' => 'That vehicle does not have enough capacity.',
      'VEHICLE_CONFLICT' => 'That vehicle has another assignment at this time.',
      'DRIVER_CONFLICT' => 'You have another driving assignment at this time.',
      _ => switch (response.statusCode) {
        401 => 'Your session expired. Sign in again.',
        403 => 'Your operator account cannot perform this action.',
        404 => 'This offer is no longer available.',
        >= 500 => 'The dispatch service is unavailable. Try again later.',
        _ => 'The offer could not be updated. Refresh and try again.',
      },
    };
    return OperatorOfferException(
      message,
      code: code,
      statusCode: response.statusCode,
    );
  }
}
