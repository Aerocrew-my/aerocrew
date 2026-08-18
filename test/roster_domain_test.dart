import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:aerocrew/features/roster/domain/transport_requirement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roster lifecycle', () {
    test('supports every canonical state and legacy review', () {
      for (final status in RosterStatus.values) {
        expect(RosterStatus.parse(status.wireName), status);
      }
      expect(RosterStatus.parse('review'), RosterStatus.needsReview);
      expect(RosterStatus.parse('unexpected'), RosterStatus.failed);
    });

    test('serializes roster and normalized duty fields safely', () {
      final roster = Roster.fromMap('roster-1', {
        'crewId': 'crew-1',
        'status': 'needs_review',
        'duties': [
          {
            'id': 'duty-1',
            'date': '2026-08-20T00:00:00+08:00',
            'flightNumber': 'MH123',
            'origin': 'KUL',
            'destination': 'BKI',
            'reportTime': '2026-08-20T08:00:00+08:00',
            'departureTime': '2026-08-20T09:30:00+08:00',
            'arrivalTime': '2026-08-20T12:00:00+08:00',
            'airport': 'KUL',
            'dutyType': 'flight',
            'confidence': 0.94,
          },
        ],
        'createdAt': '2026-08-18T00:00:00Z',
        'updatedAt': '2026-08-18T00:01:00Z',
      });
      final duty = roster.duties.single;
      expect(roster.status, RosterStatus.needsReview);
      expect(duty.origin, 'KUL');
      expect(duty.destination, 'BKI');
      expect(duty.toMap()['confidence'], 0.94);
      expect(
        duty.toMap(includeParserMetadata: false),
        isNot(contains('confidence')),
      );
      expect(roster.toMap()['status'], 'needs_review');
    });

    test('rejects duties without a stable identity', () {
      expect(
        () => RosterDuty.fromMap({'flightNumber': 'MH1'}),
        throwsFormatException,
      );
    });
  });

  group('transport requirement identity', () {
    final report = DateTime.parse('2026-08-20T08:00:00+08:00');
    final release = DateTime.parse('2026-08-20T18:00:00+08:00');

    test('calculates direction only for sectors touching the base airport', () {
      final reporting = RosterDuty(
        id: 'out',
        origin: 'KUL',
        destination: 'BKI',
        airport: 'KUL',
        reportTime: report,
      );
      final finishing = RosterDuty(
        id: 'back',
        origin: 'BKI',
        destination: 'KUL',
        airport: 'KUL',
        releaseTime: release,
      );
      final irrelevant = RosterDuty(
        id: 'other',
        origin: 'BKI',
        destination: 'PEN',
        reportTime: report,
      );
      expect(
        TransportRequirementIdentity.directionFor(reporting, 'KUL'),
        TransportDirection.toAirport,
      );
      expect(
        TransportRequirementIdentity.directionFor(finishing, 'kul'),
        TransportDirection.fromAirport,
      );
      expect(
        TransportRequirementIdentity.directionFor(irrelevant, 'KUL'),
        isNull,
      );
    });

    test('deterministic ID prevents duplicate confirmation/retry records', () {
      final duty = RosterDuty(
        id: 'out',
        flightNumber: 'MH123',
        origin: 'KUL',
        destination: 'BKI',
        airport: 'KUL',
        reportTime: report,
      );
      String id() => TransportRequirementIdentity.deterministicId(
        crewId: 'crew-1',
        rosterId: 'roster-1',
        duty: duty,
        direction: TransportDirection.toAirport,
      );
      expect(id(), id());
      expect(id(), startsWith('tr_'));
      final changed = TransportRequirementIdentity.deterministicId(
        crewId: 'crew-1',
        rosterId: 'roster-1',
        duty: duty.copyWith(flightNumber: 'MH124'),
        direction: TransportDirection.toAirport,
      );
      expect(changed, isNot(id()));
    });
  });
}
