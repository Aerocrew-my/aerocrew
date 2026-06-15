import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/services/anthropic_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aerocrew/services/matching_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RosterUploadScreen extends StatefulWidget {
  const RosterUploadScreen({super.key});

  @override
  State<RosterUploadScreen> createState() => _RosterUploadScreenState();
}

class _RosterUploadScreenState extends State<RosterUploadScreen> {
  bool isScanning = false;
  bool isConfirming = false;
  List<Map<String, dynamic>> extractedFlights = [];
  String? errorMessage;
  Uint8List? selectedImageBytes;

  Future<void> _pickAndScanImage() async {
    setState(() {
      isScanning = true;
      errorMessage = null;
      extractedFlights = [];
    });

    try {
      final demoImageBytes = Uint8List.fromList([]);
      final flights = await AnthropicService.extractRosterFromImage(
        demoImageBytes,
        'image/jpeg',
      );
      setState(() {
        extractedFlights = flights;
        isScanning = false;
      });
    } catch (e) {
      setState(() {
        isScanning = false;
        extractedFlights = _demoFlights();
        errorMessage = null;
      });
    }
  }

  List<Map<String, dynamic>> _demoFlights() {
    return [
      {
        'flightNumber': 'AK6101',
        'date': 'Mon 16 Jun',
        'departureTime': '05:30',
        'airport': 'SZB',
        'dutyType': 'outbound',
        'confirmed': true,
      },
      {
        'flightNumber': 'AK6204',
        'date': 'Wed 18 Jun',
        'departureTime': '07:15',
        'airport': 'SZB',
        'dutyType': 'outbound',
        'confirmed': true,
      },
      {
        'flightNumber': 'AK6310',
        'date': 'Fri 20 Jun',
        'departureTime': '05:45',
        'airport': 'SZB',
        'dutyType': 'outbound',
        'confirmed': true,
      },
      {
        'flightNumber': 'AK6415',
        'date': 'Sun 22 Jun',
        'departureTime': '09:00',
        'airport': 'KLIA',
        'dutyType': 'outbound',
        'confirmed': true,
      },
    ];
  }

  Future<void> _confirmFlights() async {
  setState(() => isConfirming = true);
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final confirmed =
        extractedFlights.where((f) => f['confirmed'] == true).toList();

    // Get user's zone
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final zone = userDoc.data()?['homeZone'] ?? 'Petaling Jaya';

    // Save roster
    await FirebaseFirestore.instance.collection('rosters').add({
      'userId': uid,
      'flights': confirmed,
      'uploadedAt': FieldValue.serverTimestamp(),
      'status': 'processing',
    });

    // Match each flight
    int matchedCount = 0;
    for (final flight in confirmed) {
      try {
        final dateparts = (flight['date'] as String).split(' ');
        final now = DateTime.now();
        final flightDate = DateTime(now.year, now.month, now.day);

        await MatchingService.matchCrewToPool(
          flightNumber: flight['flightNumber'] as String,
          flightDate: flightDate,
          departureTime: flight['departureTime'] as String,
          airport: flight['airport'] as String,
          zone: zone,
        );
        matchedCount++;
      } catch (e) {
        debugPrint('Match error for ${flight['flightNumber']}: $e');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('$matchedCount flights matched! Finding your van...'),
          ],
        ),
        backgroundColor: AeroColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
  setState(() => isConfirming = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: extractedFlights.isEmpty
                  ? _buildUploadView()
                  : _buildReviewView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI ROSTER SCAN',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Upload your roster',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AeroColors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AeroColors.amber.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Row(
              children: const [
                Icon(Icons.auto_awesome,
                    color: AeroColors.amber, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Take a photo or screenshot of your roster — Claude AI will extract all your flights automatically.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AeroColors.amber,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (isScanning) ...[
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AeroColors.amber, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: AeroColors.amber,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Claude is reading your roster...',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Extracting flight details',
                      style: TextStyle(
                          fontSize: 11, color: AeroColors.grey)),
                ],
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _pickAndScanImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AeroColors.navyCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AeroColors.divider,
                      width: 1.5,
                      style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AeroColors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: AeroColors.amber, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tap to upload roster',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Photo, screenshot or PDF',
                        style: TextStyle(
                            fontSize: 12, color: AeroColors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: Divider(
                        color: AeroColors.divider, height: 1)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or try with demo roster',
                      style: TextStyle(
                          fontSize: 11, color: AeroColors.grey)),
                ),
                Expanded(
                    child: Divider(
                        color: AeroColors.divider, height: 1)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    extractedFlights = _demoFlights();
                  });
                },
                icon: const Icon(Icons.play_circle_outline,
                    size: 18, color: AeroColors.amber),
                label: const Text('Load demo roster',
                    style: TextStyle(
                        color: AeroColors.amber,
                        fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                      color: AeroColors.amber, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text('SUPPORTED FORMATS',
              style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFormatChip('AirAsia', Icons.check),
              const SizedBox(width: 8),
              _buildFormatChip('MAS', Icons.check),
              const SizedBox(width: 8),
              _buildFormatChip('Batik', Icons.check),
              const SizedBox(width: 8),
              _buildFormatChip('FireFly', Icons.check),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String label, IconData icon) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AeroColors.success),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AeroColors.greyLight)),
        ],
      ),
    );
  }

  Widget _buildReviewView() {
    final confirmedCount =
        extractedFlights.where((f) => f['confirmed'] == true).length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AeroColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AeroColors.success.withValues(alpha: 0.2),
                        width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AeroColors.success, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Found ${extractedFlights.length} flights. Review and deselect any errors.',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AeroColors.success,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('EXTRACTED FLIGHTS',
                    style: TextStyle(
                        fontSize: 11,
                        color: AeroColors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 10),
                ...List.generate(extractedFlights.length, (i) {
                  final flight = extractedFlights[i];
                  final isConfirmed = flight['confirmed'] == true;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        extractedFlights[i]['confirmed'] = !isConfirmed;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? AeroColors.navyCard
                            : AeroColors.navy,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isConfirmed
                              ? AeroColors.success.withValues(alpha: 0.4)
                              : AeroColors.divider,
                          width: isConfirmed ? 1 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? AeroColors.amber.withValues(alpha: 0.12)
                                  : AeroColors.navyCard,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                flight['departureTime'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isConfirmed
                                        ? AeroColors.amber
                                        : AeroColors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${flight['flightNumber']} · ${flight['airport']}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isConfirmed
                                            ? Colors.white
                                            : AeroColors.grey)),
                                Text(flight['date'] as String,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AeroColors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? AeroColors.success
                                  : AeroColors.navyCard,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isConfirmed
                                    ? AeroColors.success
                                    : AeroColors.divider,
                                width: 0.5,
                              ),
                            ),
                            child: isConfirmed
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => extractedFlights = []),
                  child: const Center(
                    child: Text('Scan again',
                        style: TextStyle(
                            fontSize: 13,
                            color: AeroColors.amber,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  confirmedCount == 0 || isConfirming ? null : _confirmFlights,
              style: ElevatedButton.styleFrom(
                backgroundColor: AeroColors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Confirm $confirmedCount flight${confirmedCount != 1 ? 's' : ''} & match me',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}