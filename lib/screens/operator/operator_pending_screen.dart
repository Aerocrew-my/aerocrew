import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorPendingScreen extends StatelessWidget {
  const OperatorPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withOpacity(0.03),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.access_time_rounded,
                        color: AeroColors.amber, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text('Under review',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 10),
                  const Text(
                    'Our team is verifying your documents.\nYou\'ll be notified within 24–48 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: AeroColors.grey,
                        height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  _buildStatusRow(
                      'SSM Certificate', true, Icons.verified_outlined),
                  const SizedBox(height: 8),
                  _buildStatusRow(
                      'PSV Licence', true, Icons.badge_outlined),
                  const SizedBox(height: 8),
                  _buildStatusRow(
                      'Operator Permit', false, Icons.article_outlined),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AeroColors.navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AeroColors.divider, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.notifications_outlined,
                            'We\'ll notify you by email and in-app when approved'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.people_outline,
                            'You\'ll be matched with crew immediately after approval'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.payments_outlined,
                            'First earnings within 7 days of going live'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AeroColors.amber.withOpacity(0.2),
                          width: 0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline,
                            color: AeroColors.amber, size: 16),
                        SizedBox(width: 8),
                        Text('aerocrew.my@gmail.com',
                            style: TextStyle(
                                fontSize: 13,
                                color: AeroColors.amber,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool approved, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: approved ? AeroColors.infoText : AeroColors.grey,
              size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: approved
                  ? AeroColors.success.withOpacity(0.12)
                  : AeroColors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    approved
                        ? Icons.check_circle_outline
                        : Icons.sync,
                    size: 11,
                    color: approved
                        ? AeroColors.success
                        : AeroColors.amber),
                const SizedBox(width: 4),
                Text(
                    approved ? 'Received' : 'In review',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: approved
                            ? AeroColors.success
                            : AeroColors.amber)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AeroColors.grey, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AeroColors.grey,
                  height: 1.4)),
        ),
      ],
    );
  }
}