import 'dart:async';
import 'dart:typed_data';

import 'package:aerocrew/features/roster/data/roster_job_store.dart';
import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:aerocrew/screens/crew/roster_upload_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:file_selector/file_selector.dart';
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
  Future<RosterUploadAuthorization> authorizeRosterUpload({
    required String fileName,
    required String mediaType,
  }) => throw UnimplementedError();

  @override
  Future<void> uploadRosterBytes(
    RosterUploadAuthorization authorization,
    Uint8List bytes,
  ) => throw UnimplementedError();
  @override
  Future<Roster> confirmRoster(String rosterId, List<RosterDuty> duties) {
    confirmCalls++;
    return confirmCompleter.future;
  }

  @override
  Stream<Roster> watchRoster(String rosterId) =>
      Stream.value(roster(RosterStatus.needsReview));
  @override
  Future<String> createRosterJob({required String uploadId}) async => 'job_1';
  @override
  Future<Roster> getRoster(String rosterId) async =>
      roster(RosterStatus.needsReview);
  @override
  Future<void> retryRoster(String rosterId) async {}
}

class UploadFlowRepository extends FakeRosterRepository {
  UploadFlowRepository({
    this.expireFirstUpload = false,
    this.failFirstJob = false,
  });
  final bool expireFirstUpload;
  final bool failFirstJob;
  int authorizationCalls = 0;
  int uploadCalls = 0;
  int jobCalls = 0;
  final uploadIds = <String>[];

  @override
  Future<RosterUploadAuthorization> authorizeRosterUpload({
    required String fileName,
    required String mediaType,
  }) async {
    authorizationCalls++;
    return RosterUploadAuthorization(
      uploadId: 'upload_$authorizationCalls',
      uploadUrl: Uri.parse('https://storage.example/object'),
      method: 'PUT',
      headers: {'Content-Type': mediaType},
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  @override
  Future<void> uploadRosterBytes(
    RosterUploadAuthorization authorization,
    Uint8List bytes,
  ) async {
    uploadCalls++;
    if (expireFirstUpload && uploadCalls == 1) {
      throw const RosterRepositoryException(
        'expired',
        code: 'upload_authorization_expired',
      );
    }
  }

  @override
  Future<String> createRosterJob({required String uploadId}) async {
    jobCalls++;
    uploadIds.add(uploadId);
    if (failFirstJob && jobCalls == 1) {
      throw const RosterRepositoryException('Job creation failed. Try again.');
    }
    return 'job_1';
  }
}

void main() {
  Future<void> pumpUpload(
    WidgetTester tester,
    UploadFlowRepository repository,
    MemoryJobStore store,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AeroTheme.light,
        home: RosterUploadScreen(
          repository: repository,
          jobStore: store,
          pickFile: () async => XFile.fromData(
            Uint8List.fromList([37, 80, 68, 70, 45]),
            path: 'roster.pdf',
            name: 'roster.pdf',
            mimeType: 'application/pdf',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Choose roster file'));
    await tester.pumpAndSettle();
  }

  testWidgets('reauthorizes once after an expired signed upload', (
    tester,
  ) async {
    final repository = UploadFlowRepository(expireFirstUpload: true);
    final store = MemoryJobStore(null);
    await pumpUpload(tester, repository, store);
    expect(repository.authorizationCalls, 2);
    expect(repository.uploadCalls, 2);
    expect(repository.uploadIds, ['upload_2']);
    expect(store.value, 'job_1');
  });

  testWidgets('retries job creation with the same uploaded object', (
    tester,
  ) async {
    final repository = UploadFlowRepository(failFirstJob: true);
    final store = MemoryJobStore(null);
    await pumpUpload(tester, repository, store);
    expect(repository.authorizationCalls, 1);
    expect(repository.uploadCalls, 1);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(repository.authorizationCalls, 1);
    expect(repository.uploadCalls, 1);
    expect(repository.uploadIds, ['upload_1', 'upload_1']);
    expect(store.value, 'job_1');
  });

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
