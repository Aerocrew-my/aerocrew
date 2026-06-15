import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                        border: Border.all(
                            color: AeroColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ABOUT',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('AeroCrew',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AeroColors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.flight,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text('AeroCrew',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Text('Version 1.0.0',
                        style: TextStyle(
                            fontSize: 14, color: AeroColors.grey)),
                    const SizedBox(height: 6),
                    const Text('Made in Malaysia 🇲🇾',
                        style: TextStyle(
                            fontSize: 13, color: AeroColors.grey)),
                    const SizedBox(height: 32),
                    _buildInfoCard(
                      'Our mission',
                      'To eliminate the stress, inefficiency and cost of airport commuting for airline crew, while creating predictable recurring income for transport operators.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Our vision',
                      'To become the default ground transportation network for aviation professionals across Southeast Asia.',
                    ),
                    const SizedBox(height: 20),
                    _buildLinkRow('Terms of Service', Icons.description_outlined),
                    _buildLinkRow('Privacy Policy', Icons.privacy_tip_outlined),
                    _buildLinkRow('Cookie Policy', Icons.cookie_outlined),
                    _buildLinkRow('Open source licences', Icons.code),
                    const SizedBox(height: 24),
                    const Text(
                      '© 2026 AeroCrew Sdn Bhd\nAll rights reserved',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          color: AeroColors.lightGrey,
                          height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    const Text('aerocrew.my',
                        style: TextStyle(
                            fontSize: 12,
                            color: AeroColors.amber,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AeroColors.amber)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 12,
                  color: AeroColors.grey,
                  height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AeroColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.white)),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 13, color: AeroColors.grey),
        ],
      ),
    );
  }
}