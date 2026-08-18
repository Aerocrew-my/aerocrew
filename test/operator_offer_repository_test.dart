import 'dart:convert';

import 'package:aerocrew/features/offers/data/api_operator_offer_repository.dart';
import 'package:aerocrew/features/offers/data/operator_offer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> offer({String status = 'pending', String? expiresAt}) => {
  'id': 'offer-1',
  'targetType': 'pool',
  'targetId': 'pool-1',
  'serviceType': 'aeroPool',
  'airport': 'KUL',
  'direction': 'toAirport',
  'pickupAt': '2026-08-20T01:00:00.000Z',
  'requiredArrivalAt': '2026-08-20T02:00:00.000Z',
  'crewCount': 4,
  'status': status,
  'expiresAt': expiresAt ?? '2026-08-20T00:45:00.000Z',
};

void main() {
  test('authenticated request safely parses pending AeroPool offers', () async {
    late http.Request sent;
    final repository = ApiOperatorOfferRepository(
      baseUrl: 'https://admin.example/api',
      tokenProvider: (_) async => 'firebase-token',
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'offers': [offer()],
          }),
          200,
        );
      }),
    );

    final values = await repository.listOffers();
    expect(sent.headers['authorization'], 'Bearer firebase-token');
    expect(sent.url.path, '/api/v1/operator/offers');
    expect(values.single.isPool, isTrue);
    expect(values.single.crewCount, 4);
  });

  test('empty offer projection is supported', () async {
    final repository = ApiOperatorOfferRepository(
      baseUrl: 'https://admin.example/api',
      tokenProvider: (_) async => 'token',
      client: MockClient((_) async => http.Response('{"offers":[]}', 200)),
    );
    expect(await repository.listOffers(), isEmpty);
  });

  test('expired pending offer is not actionable', () async {
    final value = Map<String, dynamic>.from(
      offer(expiresAt: '2020-01-01T00:00:00.000Z'),
    );
    final parsed = await _parse(value);
    expect(parsed.isExpired, isTrue);
    expect(parsed.isPending, isFalse);
  });

  test(
    'accept sends only vehicle selection and waits for server success',
    () async {
      late http.Request sent;
      final repository = ApiOperatorOfferRepository(
        baseUrl: 'https://admin.example/api',
        tokenProvider: (_) async => 'token',
        client: MockClient((request) async {
          sent = request;
          return http.Response(
            '{"status":"accepted","targetId":"pool-1"}',
            200,
          );
        }),
      );
      await repository.accept('offer-1', vehicleId: 'vehicle-1');
      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/operator/offers/offer-1/accept');
      expect(jsonDecode(sent.body), {'vehicleId': 'vehicle-1'});
      expect(sent.body, isNot(contains('assignmentStatus')));
      expect(sent.body, isNot(contains('driverId')));
    },
  );

  test('accept conflict maps to useful UX', () async {
    final repository = ApiOperatorOfferRepository(
      baseUrl: 'https://admin.example/api',
      tokenProvider: (_) async => 'token',
      client: MockClient(
        (_) async => http.Response('{"code":"VEHICLE_CONFLICT"}', 409),
      ),
    );
    expect(
      () => repository.accept('offer-1', vehicleId: 'vehicle-1'),
      throwsA(
        isA<OperatorOfferException>().having(
          (error) => error.message,
          'message',
          contains('another assignment'),
        ),
      ),
    );
  });

  test('decline uses the canonical reason contract', () async {
    late http.Request sent;
    final repository = ApiOperatorOfferRepository(
      baseUrl: 'https://admin.example/api',
      tokenProvider: (_) async => 'token',
      client: MockClient((request) async {
        sent = request;
        return http.Response('{"status":"declined"}', 200);
      }),
    );
    await repository.decline('offer-1', OfferDeclineReason.schedule);
    expect(jsonDecode(sent.body), {'reason': 'schedule'});
  });
}

Future<dynamic> _parse(Map<String, dynamic> value) {
  // Exercise parsing through the repository's public response boundary.
  return ApiOperatorOfferRepository(
    baseUrl: 'https://admin.example/api',
    tokenProvider: (_) async => 'token',
    client: MockClient(
      (_) async => http.Response(
        jsonEncode({
          'offers': [value],
        }),
        200,
      ),
    ),
  ).listOffers().then((values) => values.single);
}
