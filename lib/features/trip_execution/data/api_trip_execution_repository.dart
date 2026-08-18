import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/execution_trip.dart';
import 'trip_execution_repository.dart';

typedef ExecutionTokenProvider = Future<String?> Function(bool forceRefresh);

class ApiTripExecutionRepository implements TripExecutionRepository {
  ApiTripExecutionRepository({
    FirebaseAuth? auth,
    http.Client? client,
    ExecutionTokenProvider? tokenProvider,
    String? baseUrl,
  }) : _auth = auth ?? (tokenProvider == null ? FirebaseAuth.instance : null),
       _client = client ?? http.Client(),
       _tokenProvider = tokenProvider,
       _baseUrl =
           baseUrl ?? const String.fromEnvironment('ROSTER_EXTRACTION_URL');
  final FirebaseAuth? _auth;
  final http.Client _client;
  final ExecutionTokenProvider? _tokenProvider;
  final String _baseUrl;
  static const _timeout = Duration(seconds: 30);

  Uri _uri(String path) {
    if (_baseUrl.trim().isEmpty) {
      throw const TripExecutionException(
        'Trip execution is not configured for this build.',
      );
    }
    return Uri.parse(
      '${_baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl}/v1/operator/trips$path',
    );
  }

  Future<Map<String, String>> _headers([bool refresh = false]) async {
    final token =
        await (_tokenProvider?.call(refresh) ??
            _auth?.currentUser?.getIdToken(refresh));
    if (token == null || token.isEmpty) {
      throw const TripExecutionException(
        'Your session expired. Sign in again.',
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
    try {
      var response = await call(await _headers()).timeout(_timeout);
      if (response.statusCode == 401) {
        response = await call(await _headers(true)).timeout(_timeout);
      }
      return response;
    } on TimeoutException {
      throw const TripExecutionException(
        'The request timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const TripExecutionException(
        'Trip execution is unavailable while offline.',
      );
    }
  }

  Map<String, dynamic> _object(String body) {
    final value = jsonDecode(body);
    if (value is! Map) throw const FormatException();
    return Map<String, dynamic>.from(value);
  }

  TripExecutionException _error(
    http.Response response,
    Map<String, dynamic> body,
  ) {
    final nested = body['error'];
    final code =
        body['code']?.toString() ??
        (nested is Map ? nested['code']?.toString() : null);
    final message = switch (response.statusCode) {
      401 => 'Your session expired. Sign in again.',
      403 => 'Your account cannot perform this action.',
      404 => 'This assignment is no longer available.',
      409 => 'This assignment has changed. The latest state has been loaded.',
      >= 500 => 'The trip service is unavailable. Try again later.',
      _ => 'The trip could not be updated. Refresh and try again.',
    };
    return TripExecutionException(
      message,
      statusCode: response.statusCode,
      code: code,
      refreshRequired: response.statusCode == 409,
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _send((h) => _client.get(_uri(path), headers: h));
    final body = _object(response.body);
    if (response.statusCode != 200) throw _error(response, body);
    return body;
  }

  Future<void> _post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await _send(
      (h) => _client.post(_uri(path), headers: h, body: jsonEncode(body)),
    );
    final value = _object(response.body);
    if (response.statusCode != 200) throw _error(response, value);
  }

  @override
  Future<List<ExecutionTrip>> getActiveAssignments() async {
    final body = await _get('');
    final trips = body['trips'];
    if (trips is! List) {
      throw const TripExecutionException(
        'The trip service returned malformed data.',
      );
    }
    return trips
        .whereType<Map>()
        .map((v) => ExecutionTrip.fromMap(Map<String, dynamic>.from(v)))
        .toList();
  }

  @override
  Future<ExecutionTrip> getTrip(String id) async {
    final body = await _get('/${Uri.encodeComponent(id)}');
    final trip = body['trip'];
    if (trip is! Map) {
      throw const TripExecutionException(
        'The trip service returned malformed data.',
      );
    }
    return ExecutionTrip.fromMap(Map<String, dynamic>.from(trip));
  }

  Future<void> _action(String id, String action) =>
      _post('/${Uri.encodeComponent(id)}/$action');
  @override
  Future<void> startPickup(String id) => _action(id, 'start-pickup');
  @override
  Future<void> arrivePickup(String id) => _action(id, 'arrive-pickup');
  @override
  Future<void> markCrewOnboard(String id) => _action(id, 'crew-onboard');
  @override
  Future<void> startAirportLeg(String id) => _action(id, 'start-airport');
  @override
  Future<void> completeTrip(String id) => _action(id, 'complete');
  Future<void> _stop(
    String id,
    String stopId,
    String action, [
    Map<String, dynamic> body = const {},
  ]) => _post(
    '/${Uri.encodeComponent(id)}/stops/${Uri.encodeComponent(stopId)}/$action',
    body,
  );
  @override
  Future<void> markStopArrived(String id, String stopId) =>
      _stop(id, stopId, 'arrive');
  @override
  Future<void> markStopOnboard(String id, String stopId) =>
      _stop(id, stopId, 'onboard');
  @override
  Future<void> markStopException(
    String id,
    String stopId,
    StopExceptionReason reason, {
    String? detail,
  }) => _stop(id, stopId, 'exception', {
    'reason': switch (reason) {
      StopExceptionReason.crewNoShow => 'crew_no_show',
      StopExceptionReason.crewCancelled => 'crew_cancelled',
      StopExceptionReason.unsafePickup => 'unsafe_pickup',
      StopExceptionReason.unableToAccess => 'unable_to_access',
      StopExceptionReason.operatorIssue => 'operator_issue',
      StopExceptionReason.other => 'other',
    },
    if (detail?.trim().isNotEmpty == true) 'detail': detail!.trim(),
  });
}
