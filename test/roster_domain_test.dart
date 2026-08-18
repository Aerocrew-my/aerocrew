import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'roster status supports canonical lifecycle and legacy review alias',
    () {
      expect(RosterStatus.parse('queued'), RosterStatus.queued);
      expect(RosterStatus.parse('needs_review'), RosterStatus.needsReview);
      expect(RosterStatus.parse('review'), RosterStatus.needsReview);
      expect(RosterStatus.parse('unexpected'), RosterStatus.failed);
      expect(RosterStatus.needsReview.wireName, 'needs_review');
    },
  );

  test(
    'roster response serialization preserves canonical status and duties',
    () {
      final roster = Roster.fromMap('roster-1', {
        'crewId': 'crew-1',
        'status': 'needs_review',
        'duties': [
          {
            'id': 'duty-1',
            'flightNumber': 'MH123',
            'airport': 'KUL',
            'reportAt': '2026-08-20T08:00:00+08:00',
            'confirmed': false,
          },
        ],
        'createdAt': '2026-08-18T00:00:00Z',
        'updatedAt': '2026-08-18T00:01:00Z',
      });

      expect(roster.crewId, 'crew-1');
      expect(roster.status, RosterStatus.needsReview);
      expect(roster.duties.single.flightNumber, 'MH123');
      expect(roster.toMap()['status'], 'needs_review');
    },
  );
}
