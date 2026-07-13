import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/crew_dashboard_screen.dart';

class StaffIdScreen extends StatelessWidget {
  const StaffIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AeroColors.amberLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: AeroColors.amber,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Staff ID verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AeroColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload a photo of your airline staff ID.\nAdmin will verify within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AeroColors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AeroColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AeroColors.amberBorder,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: AeroColors.amber,
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to upload staff ID',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AeroColors.amber,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JPG or PNG, max 5MB',
                      style: TextStyle(fontSize: 12, color: AeroColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AeroColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AeroColors.infoText.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      color: AeroColors.infoText,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your ID is stored securely and only used for verification purposes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AeroColors.infoText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CrewDashboardScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AeroColors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit for verification',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrewDashboardScreen(),
                  ),
                ),
                child: const Text(
                  'Skip for now',
                  style: TextStyle(color: AeroColors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
