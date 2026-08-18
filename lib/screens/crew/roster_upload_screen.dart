import 'dart:async';
import 'dart:typed_data';

import 'package:aerocrew/features/roster/data/api_roster_repository.dart';
import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/data/roster_job_store.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class RosterUploadScreen extends StatefulWidget {
  const RosterUploadScreen({
    super.key,
    this.repository,
    this.jobStore,
    this.onConfirmed,
    this.pickFile,
  });
  final RosterRepository? repository;
  final RosterJobStore? jobStore;
  final VoidCallback? onConfirmed;
  final Future<XFile?> Function()? pickFile;

  @override
  State<RosterUploadScreen> createState() => _RosterUploadScreenState();
}

class _RosterUploadScreenState extends State<RosterUploadScreen> {
  late final RosterRepository _repository;
  late final RosterJobStore _jobStore;
  StreamSubscription<Roster>? _subscription;
  Roster? _roster;
  String? _error;
  bool _selecting = false;
  bool _uploading = false;
  bool _confirming = false;
  String? _uploadState;
  String? _pendingUploadId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ApiRosterRepository();
    _jobStore = widget.jobStore ?? PreferencesRosterJobStore();
    _resumeCurrentJob();
  }

  Future<void> _resumeCurrentJob() async {
    final id = await _jobStore.load();
    if (!mounted || id == null || id.isEmpty) return;
    await _watch(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _selectAndUpload() async {
    setState(() {
      _selecting = true;
      _error = null;
    });
    const types = XTypeGroup(
      label: 'Roster files',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
      mimeTypes: ['application/pdf', 'image/jpeg', 'image/png'],
    );
    try {
      final file =
          await (widget.pickFile?.call() ??
              openFile(acceptedTypeGroups: const [types]));
      if (file == null) return;
      final extension = file.name.split('.').last.toLowerCase();
      final mediaType = switch (extension) {
        'pdf' => 'application/pdf',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        _ => null,
      };
      if (mediaType == null) {
        throw const RosterRepositoryException(
          'Choose a PDF, JPG, JPEG, or PNG file.',
        );
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const RosterRepositoryException('The selected file is empty.');
      }
      if (bytes.length > 12 * 1024 * 1024) {
        throw const RosterRepositoryException(
          'Choose a roster smaller than 12 MB.',
        );
      }
      if (!mounted) return;
      setState(() {
        _uploading = true;
        _uploadState = 'Preparing upload';
      });
      await _authorizeUploadAndCreateJob(
        bytes: bytes,
        mediaType: mediaType,
        fileName: file.name,
      );
    } on RosterRepositoryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The roster could not be uploaded. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _selecting = false;
          _uploading = false;
          _uploadState = null;
        });
      }
    }
  }

  Future<void> _authorizeUploadAndCreateJob({
    required Uint8List bytes,
    required String mediaType,
    required String fileName,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final authorization = await _repository.authorizeRosterUpload(
        fileName: fileName,
        mediaType: mediaType,
      );
      if (mounted) setState(() => _uploadState = 'Uploading roster');
      try {
        await _repository.uploadRosterBytes(authorization, bytes);
      } on RosterRepositoryException catch (error) {
        if (error.code == 'upload_authorization_expired' && attempt == 0) {
          if (mounted) setState(() => _uploadState = 'Preparing upload');
          continue;
        }
        rethrow;
      }
      _pendingUploadId = authorization.uploadId;
      await _createPendingJob();
      return;
    }
  }

  Future<void> _createPendingJob() async {
    final uploadId = _pendingUploadId;
    if (uploadId == null) return;
    if (mounted) setState(() => _uploadState = 'Creating roster job');
    final id = await _repository.createRosterJob(uploadId: uploadId);
    _pendingUploadId = null;
    await _jobStore.save(id);
    await _watch(id);
  }

  Future<void> _watch(String id) async {
    await _subscription?.cancel();
    _subscription = _repository
        .watchRoster(id)
        .listen(
          (roster) {
            if (mounted) {
              setState(() {
                _roster = roster;
                _error = null;
              });
            }
          },
          onError: (Object error) {
            if (mounted) {
              setState(
                () => _error = error is RosterRepositoryException
                    ? error.message
                    : 'Roster status could not be loaded.',
              );
            }
          },
        );
  }

  Future<void> _retry() async {
    final roster = _roster;
    if (roster == null) {
      if (_pendingUploadId != null) {
        try {
          setState(() {
            _error = null;
            _uploading = true;
          });
          await _createPendingJob();
        } on RosterRepositoryException catch (error) {
          if (mounted) setState(() => _error = error.message);
        } finally {
          if (mounted) {
            setState(() {
              _uploading = false;
              _uploadState = null;
            });
          }
        }
        return;
      }
      await _selectAndUpload();
      return;
    }
    try {
      setState(() => _error = null);
      await _repository.retryRoster(roster.id);
      await _watch(roster.id);
    } on RosterRepositoryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  Future<void> _confirm() async {
    if (_confirming) return;
    final roster = _roster;
    if (roster == null || roster.status != RosterStatus.needsReview) return;
    final duties = roster.duties.where((duty) => duty.confirmed).toList();
    if (duties.isEmpty) {
      setState(() => _error = 'Select at least one duty before confirming.');
      return;
    }
    try {
      setState(() {
        _confirming = true;
        _error = null;
      });
      final confirmed = await _repository.confirmRoster(
        roster.id,
        roster.duties,
      );
      if (!mounted) return;
      setState(() => _roster = confirmed);
      widget.onConfirmed?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Roster confirmed. Transport generation is processing.',
          ),
        ),
      );
    } on RosterRepositoryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  void _replaceDuty(int index, RosterDuty duty) {
    final roster = _roster!;
    final duties = [...roster.duties]..[index] = duty;
    setState(
      () => _roster = Roster(
        id: roster.id,
        crewId: roster.crewId,
        status: roster.status,
        duties: duties,
        createdAt: roster.createdAt,
        updatedAt: roster.updatedAt,
        sourceFileName: roster.sourceFileName,
        errorMessage: roster.errorMessage,
      ),
    );
  }

  Future<void> _editDuty(int index) async {
    final duty = _roster!.duties[index];
    final flight = TextEditingController(text: duty.flightNumber);
    final origin = TextEditingController(text: duty.origin);
    final destination = TextEditingController(text: duty.destination);
    final airport = TextEditingController(text: duty.airport);
    final report = TextEditingController(
      text: duty.reportTime?.toIso8601String(),
    );
    final release = TextEditingController(
      text: duty.releaseTime?.toIso8601String(),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct duty'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: flight,
                decoration: const InputDecoration(labelText: 'Flight number'),
              ),
              TextField(
                controller: origin,
                decoration: const InputDecoration(labelText: 'Origin'),
              ),
              TextField(
                controller: destination,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              TextField(
                controller: airport,
                decoration: const InputDecoration(labelText: 'Base airport'),
              ),
              TextField(
                controller: report,
                decoration: const InputDecoration(
                  labelText: 'Report time (ISO 8601)',
                ),
              ),
              TextField(
                controller: release,
                decoration: const InputDecoration(
                  labelText: 'Release time (ISO 8601)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final reportAt = DateTime.tryParse(report.text.trim());
    final releaseAt = DateTime.tryParse(release.text.trim());
    if ((report.text.trim().isNotEmpty && reportAt == null) ||
        (release.text.trim().isNotEmpty && releaseAt == null)) {
      setState(() => _error = 'Use a valid ISO 8601 report/release time.');
      return;
    }
    _replaceDuty(
      index,
      duty.copyWith(
        flightNumber: flight.text.trim(),
        origin: origin.text.trim(),
        destination: destination.text.trim(),
        airport: airport.text.trim(),
        reportTime: reportAt,
        releaseTime: releaseAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AeroAppBar(
        title: 'Upload roster',
        subtitle: 'Secure parsing and duty review',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(AeroSpacing.screen),
            children: [
              if (_error != null) ...[
                AeroErrorState(message: _error!, onRetry: _retry),
                const SizedBox(height: 16),
              ],
              if (_roster == null) _uploadCard() else _rosterView(_roster!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadCard() => AeroCard(
    child: Column(
      children: [
        Icon(
          Icons.document_scanner_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Select a roster image or PDF',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'The file is submitted to the secure roster service. Queued work remains visibly queued until parsing finishes.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        AeroButton(
          label: _selecting
              ? 'Selecting…'
              : _uploading
              ? '${_uploadState ?? 'Uploading roster'}…'
              : 'Choose roster file',
          icon: Icons.upload_file,
          expand: true,
          onPressed: _selecting || _uploading ? null : _selectAndUpload,
        ),
      ],
    ),
  );

  Widget _rosterView(Roster roster) {
    if (roster.status != RosterStatus.needsReview &&
        roster.status != RosterStatus.confirmed) {
      return AeroCard(
        child: Column(
          children: [
            if (roster.status != RosterStatus.failed)
              const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _statusLabel(roster.status),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (roster.errorMessage != null)
              Text(roster.errorMessage!, textAlign: TextAlign.center),
            if (roster.status == RosterStatus.failed) ...[
              const SizedBox(height: 16),
              AeroButton(label: 'Retry processing', onPressed: _retry),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        AeroCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _statusLabel(roster.status),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AeroStatusChip(
                label: roster.status == RosterStatus.confirmed
                    ? 'Confirmed'
                    : 'Review required',
                color: roster.status == RosterStatus.confirmed
                    ? context.aero.success
                    : context.aero.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(roster.duties.length, (index) {
          final duty = roster.duties[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AeroCard(
              child: Row(
                children: [
                  Checkbox(
                    value: duty.confirmed,
                    onChanged: roster.status == RosterStatus.confirmed
                        ? null
                        : (value) => _replaceDuty(
                            index,
                            duty.copyWith(confirmed: value ?? false),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duty.flightNumber?.isNotEmpty == true
                              ? duty.flightNumber!
                              : 'Duty ${index + 1}',
                        ),
                        Text(
                          '${duty.origin ?? 'Origin pending'} → ${duty.destination ?? 'Destination pending'}',
                        ),
                        Text(
                          duty.reportTime?.toLocal().toString() ??
                              duty.releaseTime?.toLocal().toString() ??
                              'Time pending',
                        ),
                      ],
                    ),
                  ),
                  if (roster.status != RosterStatus.confirmed)
                    IconButton(
                      onPressed: () => _editDuty(index),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
            ),
          );
        }),
        if (roster.status == RosterStatus.needsReview)
          AeroButton(
            label: _confirming ? 'Confirming…' : 'Confirm reviewed roster',
            icon: Icons.check,
            expand: true,
            onPressed: _confirming ? null : _confirm,
          ),
      ],
    );
  }

  String _statusLabel(RosterStatus status) => switch (status) {
    RosterStatus.uploaded => 'Roster uploaded',
    RosterStatus.queued => 'Roster queued',
    RosterStatus.processing => 'Parsing roster',
    RosterStatus.needsReview => 'Review parsed duties',
    RosterStatus.confirmed => 'Roster confirmed',
    RosterStatus.failed => 'Roster processing failed',
  };
}
