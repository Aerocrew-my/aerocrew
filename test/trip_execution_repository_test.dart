import 'dart:convert';
import 'package:aerocrew/features/trip_execution/data/api_trip_execution_repository.dart';
import 'package:aerocrew/features/trip_execution/data/trip_execution_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<http.Request> requests;
  ApiTripExecutionRepository repository(
    http.Response Function(http.Request) response,
  ) {
    requests = [];
    return ApiTripExecutionRepository(
      baseUrl: 'https://api.example',
      tokenProvider: (_) async => 'token',
      client: MockClient((request) async {
        requests.add(request);
        return response(request);
      }),
    );
  }

  test('parses active assignments and privacy-safe stop progress', () async {
    final repo = repository(
      (_) => http.Response(
        jsonEncode({
          'trips': [
            {
              'id': 't1',
              'status': 'driverArrived',
              'serviceType': 'aeroPool',
              'pickupStops': [
                {
                  'id': 's2',
                  'sequence': 1,
                  'status': 'pending',
                  'crewId': 'secret',
                },
                {'id': 's1', 'sequence': 0, 'status': 'onboard'},
              ],
            },
          ],
        }),
        200,
      ),
    );
    final trips = await repo.getActiveAssignments();
    expect(trips.single.resolvedStops, 1);
    expect(trips.single.stops.first.id, 's1');
    expect(trips.single.stops.first.toString(), isNot(contains('secret')));
  });

  test('start pickup uses protected trusted route', () async {
    final repo = repository(
      (_) => http.Response('{"status":"driverEnRoute"}', 200),
    );
    await repo.startPickup('trip 1');
    expect(requests.single.method, 'POST');
    expect(
      requests.single.url.path,
      '/v1/operator/trips/trip%201/start-pickup',
    );
    expect(requests.single.headers['authorization'], 'Bearer token');
  });

  test('parses wrapped trip detail and Firestore timestamps', () async {
    final repo = repository(
      (_) => http.Response(
        jsonEncode({
          'trip': {
            'id': 't1',
            'status': 'accepted',
            'serviceType': 'aeroSolo',
            'scheduledPickupAt': {'_seconds': 1787040000},
          },
        }),
        200,
      ),
    );
    final trip = await repo.getTrip('t1');
    expect(trip.id, 't1');
    expect(trip.scheduledPickupAt, isNotNull);
  });

  test(
    'supports arrival, onboard, airport leg and completion routes',
    () async {
      final repo = repository((_) => http.Response('{}', 200));
      await repo.arrivePickup('t');
      await repo.markCrewOnboard('t');
      await repo.startAirportLeg('t');
      await repo.completeTrip('t');
      expect(
        requests.map((r) => r.url.path),
        containsAll([
          '/v1/operator/trips/t/arrive-pickup',
          '/v1/operator/trips/t/crew-onboard',
          '/v1/operator/trips/t/start-airport',
          '/v1/operator/trips/t/complete',
        ]),
      );
    },
  );

  test('supports pool stop progression and confirmed no-show reason', () async {
    final repo = repository((_) => http.Response('{}', 200));
    await repo.markStopArrived('t', 's');
    await repo.markStopOnboard('t', 's');
    await repo.markStopException('t', 's', StopExceptionReason.crewNoShow);
    expect(requests.last.url.path, '/v1/operator/trips/t/stops/s/exception');
    expect(jsonDecode(requests.last.body)['reason'], 'crew_no_show');
  });

  test('409 asks caller to refresh without exposing raw JSON', () async {
    final repo = repository(
      (_) =>
          http.Response('{"code":"STALE_TRIP_STATE","internal":"secret"}', 409),
    );
    await expectLater(
      repo.startPickup('t'),
      throwsA(
        isA<TripExecutionException>()
            .having((e) => e.refreshRequired, 'refreshRequired', true)
            .having((e) => e.message, 'message', isNot(contains('secret'))),
      ),
    );
  });

  test('401 retries once with a fresh token', () async {
    var calls = 0;
    final repo = repository(
      (_) => http.Response('{}', ++calls == 1 ? 401 : 200),
    );
    await repo.startPickup('t');
    expect(calls, 2);
  });
}
