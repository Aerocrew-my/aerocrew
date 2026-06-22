import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool isActivated = false;
  int countdown = 5;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _activateSOS() {
    setState(() {
      isActivated = true;
      countdown = 5;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        t.cancel();
        // In production: send SOS to emergency contacts + AeroCrew support
      }
    });
  }

  void _cancelSOS() {
    _countdownTimer?.cancel();
    setState(() {
      isActivated = false;
      countdown = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                        border:
                            Border.all(color: AeroColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Emergency SOS',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isActivated) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AeroColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AeroColors.danger.withValues(alpha: 0.2),
                              width: 0.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AeroColors.danger, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Press SOS to alert AeroCrew support and your emergency contacts with your current location.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AeroColors.danger,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: _activateSOS,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 180 +
                                      (_pulseController.value * 20),
                                  height: 180 +
                                      (_pulseController.value * 20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AeroColors.danger.withValues(
                                        alpha: 0.1 *
                                            (1 - _pulseController.value)),
                                  ),
                                ),
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AeroColors.danger,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AeroColors.danger
                                            .withValues(alpha: 0.4),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.sos,
                                          color: Colors.white, size: 48),
                                      Text('PRESS',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Hold only for genuine emergencies',
                        style: TextStyle(
                            fontSize: 13, color: AeroColors.grey),
                      ),
                    ] else ...[
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AeroColors.danger,
                          boxShadow: [
                            BoxShadow(
                              color: AeroColors.danger.withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text('$countdown',
                              style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('SOS sending in...',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text(
                          'Your location is being shared with\nAeroCrew support and emergency contacts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: AeroColors.grey,
                              height: 1.5)),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _cancelSOS,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AeroColors.grey,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            side: const BorderSide(
                                color: AeroColors.divider),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel SOS',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildEmergencyContacts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EMERGENCY CONTACTS', style: AeroText.label),
          const SizedBox(height: 10),
          _buildContact('AeroCrew Support', '+60 3-XXXX XXXX',
              Icons.headset_mic_outlined, AeroColors.amber),
          _buildContact('Police Emergency', '999',
              Icons.local_police_outlined, AeroColors.danger),
          _buildContact('Ambulance', '999',
              Icons.medical_services_outlined, AeroColors.success),
        ],
      ),
    );
  }

  Widget _buildContact(
      String name, String number, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                Text(number,
                    style: const TextStyle(
                        fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Call',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }
}