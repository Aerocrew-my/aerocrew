import 'dart:async';
import 'dart:typed_data';

import 'package:aerocrew/features/roster/data/roster_job_store.dart';
import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:aerocrew/screens/crew/roster_upload_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Roster roster(RosterStatus status) => Roster(
  id: 'job_1',
  crewId: 'crew_1',
  status: status,
  duties: const [RosterDuty(id: 'duty_1', flightNumber: 'MH123')],
  createdAt: DateTime.utc(2026, 8, 18),
  updatedAt: DateTime.utc(2026, 8, 18),
);

class MemoryJobStore implements RosterJobStore {
  MemoryJobStore(this.value);
  String? value;
  @override
  Future<String?> load() async => value;
  @override
  Future<void> save(String jobId) async => value = jobId;
}

class FakeRosterRepository implements RosterRepository {
  final confirmCompleter = Completer<Roster>();
  int confirmCalls = 0;
  @override
  Future<Roster> confirmRoster(String rosterId, List<RosterDuty> duties) {
    confirmCalls++;
    return confirmCompleter.future;
  }

  @override
  Stream<Roster> watchRoster(String rosterId) =>
      Stream.value(roster(RosterStatus.needsReview));
  @override
  Future<String> createRosterJob({
    required Uint8List bytes,
    required String mediaType,
    required String fileName,
  }) async => 'job_1';
  @override
  Future<Roster> getRoster(String rosterId) async =>
      roster(RosterStatus.needsReview);
  @override
  Future<void> retryRoster(String rosterId) async {}
}

void main() {
  testWidgets(
    'prevents duplicate confirm and refreshes dashboard after success',
    (tester) async {
      final repository = FakeRosterRepository();
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AeroTheme.light,
          home: RosterUploadScreen(
            repository: repository,
            jobStore: MemoryJobStore('job_1'),
            onConfirmed: () => refreshes++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Confirm reviewed roster'));
      await tester.pump();
      await tester.tap(find.text('Confirming…'));
      expect(repository.confirmCalls, 1);
      repository.confirmCompleter.complete(roster(RosterStatus.confirmed));
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      expect(find.text('Roster confirmed'), findsOneWidget);
    },
  );
}
