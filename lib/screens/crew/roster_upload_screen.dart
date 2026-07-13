import 'dart:typed_data';

import 'package:aerocrew/services/anthropic_service.dart';
import 'package:aerocrew/services/matching_service.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum _RosterStage { upload, processing, review }

class RosterUploadScreen extends StatefulWidget {
  const RosterUploadScreen({super.key});

  @override
  State<RosterUploadScreen> createState() => _RosterUploadScreenState();
}

class _RosterUploadScreenState extends State<RosterUploadScreen> {
  _RosterStage _stage = _RosterStage.upload;
  List<Map<String, dynamic>> _duties = const [];
  String? _fileName;
  String? _error;
  bool _confirming = false;

  Future<void> _selectAndExtract() async {
    setState(() => _error = null);
    const rosterFiles = XTypeGroup(
      label: 'Roster files',
      extensions: ['jpg', 'jpeg', 'png', 'pdf'],
      mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
    );
    final file = await openFile(acceptedTypeGroups: const [rosterFiles]);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > 12 * 1024 * 1024) {
      setState(
        () => _error = 'Choose a non-empty roster file smaller than 12 MB.',
      );
      return;
    }
    final extension = file.name.split('.').last.toLowerCase();
    final mediaType = switch (extension) {
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => 'image/jpeg',
    };
    setState(() {
      _fileName = file.name;
      _stage = _RosterStage.processing;
    });
    await _extract(bytes, mediaType);
  }

  Future<void> _extract(Uint8List bytes, String mediaType) async {
    try {
      final duties = await AnthropicService.extractRoster(bytes, mediaType);
      if (!mounted) return;
      if (duties.isEmpty) {
        setState(() {
          _stage = _RosterStage.upload;
          _error =
              'No duties were detected. Use a clearer roster file or contact support.';
        });
        return;
      }
      setState(() {
        _duties = duties.map((duty) {
          final next = Map<String, dynamic>.from(duty);
          next['confirmed'] = duty['confirmed'] != false;
          next['uncertain'] =
              duty['uncertain'] == true ||
              duty['confidence'] is num && (duty['confidence'] as num) < 0.8;
          return next;
        }).toList();
        _stage = _RosterStage.review;
      });
    } on RosterExtractionException catch (error) {
      if (!mounted) return;
      setState(() {
        _stage = _RosterStage.upload;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stage = _RosterStage.upload;
        _error = 'The roster could not be processed. Try again later.';
      });
    }
  }

  Future<void> _confirm() async {
    final user = FirebaseAuth.instance.currentUser;
    final confirmed = _duties
        .where((duty) => duty['confirmed'] == true)
        .toList();
    if (user == null || confirmed.isEmpty) return;
    setState(() => _confirming = true);
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final zone = profile.data()?['homeZone'] as String? ?? 'Petaling Jaya';
      final roster = await FirebaseFirestore.instance
          .collection('rosters')
          .add({
            'userId': user.uid,
            'sourceFileName': _fileName,
            'flights': confirmed,
            'uploadedAt': FieldValue.serverTimestamp(),
            'status': 'confirmed',
          });

      var generated = 0;
      for (final duty in confirmed) {
        final date = _parseDutyDate(duty['date']?.toString());
        if (date == null) continue;
        try {
          await MatchingService.matchCrewToPool(
            flightNumber: duty['flightNumber']?.toString() ?? '',
            flightDate: date,
            departureTime: duty['departureTime']?.toString() ?? '',
            airport: duty['airport']?.toString() ?? '',
            zone: zone,
          );
          generated++;
        } catch (_) {
          // The confirmed roster remains saved for server-side recovery.
        }
      }
      await roster.update({
        'status': generated == confirmed.length
            ? 'transport_generated'
            : 'requires_processing',
        'transportRequirementsGenerated': generated,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$generated of ${confirmed.length} transport requirements generated.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The roster could not be confirmed. Try again.'),
        ),
      );
      setState(() => _confirming = false);
    }
  }

  DateTime? _parseDutyDate(String? value) {
    if (value == null) return null;
    final match = RegExp(
      r'(\d{1,2})\s+([A-Za-z]{3})(?:\s+(\d{4}))?',
    ).firstMatch(value);
    if (match == null) return null;
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final month = months[match.group(2)!.toLowerCase()];
    if (month == null) return null;
    final now = DateTime.now();
    var year = int.tryParse(match.group(3) ?? '') ?? now.year;
    var date = DateTime(year, month, int.parse(match.group(1)!));
    if (match.group(3) == null &&
        date.isBefore(now.subtract(const Duration(days: 60)))) {
      year++;
      date = DateTime(year, month, int.parse(match.group(1)!));
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AeroAppBar(
        title: 'Upload roster',
        subtitle: 'Validate, review, and confirm duties',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: switch (_stage) {
            _RosterStage.upload => _uploadView(),
            _RosterStage.processing => _processingView(),
            _RosterStage.review => _reviewView(),
          },
        ),
      ),
    );
  }

  Widget _uploadView() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      AeroCard(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.aero.blueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a roster image or PDF',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'We validate the file before extracting duties. You will review every detected entry before transport is generated.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.aero.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AeroButton(
              label: 'Choose roster file',
              icon: Icons.upload_file,
              expand: true,
              onPressed: _selectAndExtract,
            ),
          ],
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 16),
        AeroCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: context.aero.information),
              const SizedBox(width: 12),
              Expanded(child: Text(_error!)),
            ],
          ),
        ),
      ],
      const SizedBox(height: 24),
      const AeroSectionHeader(title: 'What happens next'),
      const SizedBox(height: 12),
      const AeroCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            AeroListTile(
              icon: Icons.verified_outlined,
              title: '1. Validate file',
            ),
            Divider(height: 1),
            AeroListTile(
              icon: Icons.manage_search_outlined,
              title: '2. Extract and review duties',
            ),
            Divider(height: 1),
            AeroListTile(
              icon: Icons.route_outlined,
              title: '3. Generate transport requirements',
            ),
          ],
        ),
      ),
    ],
  );

  Widget _processingView() =>
      const AeroLoadingState(label: 'Validating and extracting roster duties');

  Widget _reviewView() {
    final confirmed = _duties.where((duty) => duty['confirmed'] == true).length;
    final uncertain = _duties.where((duty) => duty['uncertain'] == true).length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AeroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_duties.length} duties detected',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$confirmed confirmed automatically · $uncertain require review',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.aero.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AeroSectionHeader(title: 'Review detected duties'),
              const SizedBox(height: 12),
              ...List.generate(_duties.length, (index) => _dutyCard(index)),
              TextButton(
                onPressed: () => setState(() {
                  _stage = _RosterStage.upload;
                  _duties = const [];
                }),
                child: const Text('Choose another file'),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.aero.surface,
            border: Border(top: BorderSide(color: context.aero.border)),
          ),
          child: AeroButton(
            label: _confirming ? 'Confirming…' : 'Confirm $confirmed duties',
            icon: Icons.check,
            expand: true,
            onPressed: _confirming || confirmed == 0 ? null : _confirm,
          ),
        ),
      ],
    );
  }

  Widget _dutyCard(int index) {
    final duty = _duties[index];
    final selected = duty['confirmed'] == true;
    final uncertain = duty['uncertain'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AeroCard(
        onTap: () => setState(() => _duties[index]['confirmed'] = !selected),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) =>
                  setState(() => _duties[index]['confirmed'] = value ?? false),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${duty['flightNumber'] ?? 'Duty'} · ${duty['airport'] ?? 'Airport pending'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${duty['date'] ?? 'Date pending'} · ${duty['departureTime'] ?? 'Time pending'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (uncertain)
              AeroStatusChip(
                label: 'Review',
                color: context.aero.warning,
                icon: Icons.warning_amber,
              ),
          ],
        ),
      ),
    );
  }
}
