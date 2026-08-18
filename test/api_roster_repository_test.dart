import 'dart:convert';
import 'dart:typed_data';

import 'package:aerocrew/features/roster/data/api_roster_repository.dart';
import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> rosterJson(String status) => {
  'jobId': 'job_1',
  'crewId': 'crew_1',
  'status': status,
  'duties': [
    {
      'id': 'duty_1',
      'flightNumber': 'MH123',
      'origin': 'KUL',
      'destination': 'PEN',
      'reportTime': '2026-08-20T08:00:00+08:00',
      'confidence': 0.9,
    },
  ],
  'createdAt': '2026-08-18T00:00:00Z',
  'updatedAt': '2026-08-18T00:01:00Z',
};

ApiRosterRepository repository(
  MockClient client, {
  Future<String?> Function(bool)? tokens,
}) => ApiRosterRepository(
  client: client,
  baseUrl: 'http://localhost:3000/api',
  tokenProvider: tokens ?? (_) async => 'token',
  pollingInterval: Duration.zero,
);

void main() {
  test(
    'includes an authorization header and uses the exact server route',
    () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'http://localhost:3000/api/v1/roster-jobs',
        );
        expect(request.headers['authorization'], 'Bearer fresh-token');
        return http.Response(
          jsonEncode({'jobId': 'job_1', 'status': 'queued'}),
          202,
        );
      });
      await repository(
        client,
        tokens: (_) async => 'fresh-token',
      ).createRosterJob(
        bytes: Uint8List.fromList([1]),
        mediaType: 'application/pdf',
        fileName: 'roster.pdf',
      );
    },
  );

  test('refreshes the token once after a server 401', () async {
    final forced = <bool>[];
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (calls == 1) return http.Response('{}', 401);
      expect(request.headers['authorization'], 'Bearer refreshed');
      return http.Response(jsonEncode(rosterJson('needs_review')), 200);
    });
    final result = await repository(
      client,
      tokens: (force) async {
        forced.add(force);
        return force ? 'refreshed' : 'cached';
      },
    ).getRoster('job_1');
    expect(result.status, RosterStatus.needsReview);
    expect(forced, [false, true]);
  });

  for (final status in [401, 403, 409, 422, 500]) {
    test('surfaces server $status safely', () async {
      final client = MockClient(
        (_) async => http.Response(
          status == 403
              ? jsonEncode({
                  'error': {'code': 'forbidden', 'message': 'Denied'},
                })
              : '{}',
          status,
        ),
      );
      try {
        await repository(client).getRoster('job_1');
        fail('Expected an exception');
      } on RosterRepositoryException catch (error) {
        expect(error.statusCode, status);
        expect(error.message, isNotEmpty);
        if (status == 403) {
          expect(error.code, 'forbidden');
          expect(error.message, 'Denied');
        }
      }
    });
  }

  for (final terminal in ['needs_review', 'confirmed', 'failed']) {
    test('polling terminates at $terminal', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response(jsonEncode(rosterJson(terminal)), 200);
      });
      final values = await repository(client).watchRoster('job_1').toList();
      expect(values, hasLength(1));
      expect(calls, 1);
    });
  }

  test('retry calls the trusted retry endpoint', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'http://localhost:3000/api/v1/roster-jobs/job_1/retry',
      );
      return http.Response('', 202);
    });
    await repository(client).retryRoster('job_1');
  });

  test('confirmation sends only selected whitelisted duty fields', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'http://localhost:3000/api/v1/roster-jobs/job_1/confirm',
      );
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final duty = (body['duties'] as List).single as Map<String, dynamic>;
      expect(
        duty.keys,
        containsAll(['id', 'flightNumber', 'origin', 'destination']),
      );
      expect(duty, isNot(contains('confidence')));
      expect(duty, isNot(contains('confirmed')));
      return http.Response(jsonEncode(rosterJson('confirmed')), 200);
    });
    final duty = RosterDuty.fromMap(
      Map<String, dynamic>.from(
        (rosterJson('needs_review')['duties'] as List).single as Map,
      ),
    );
    final result = await repository(client).confirmRoster('job_1', [duty]);
    expect(result.status, RosterStatus.confirmed);
  });

  test(
    'does not accept generic success when confirmation is not confirmed',
    () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(rosterJson('needs_review')), 200),
      );
      final duty = RosterDuty.fromMap({'id': 'duty_1'});
      expect(
        repository(client).confirmRoster('job_1', [duty]),
        throwsA(isA<RosterRepositoryException>()),
      );
    },
  );
}
