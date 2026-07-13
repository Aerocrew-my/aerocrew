import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key});

  final List<Map<String, dynamic>> changelog = const [
    {
      'version': '1.0.0',
      'date': 'June 2026',
      'isLatest': true,
      'changes': [
        'AI-powered roster scanning with Claude',
        'AeroPool, AeroFlex and AeroSolo products',
        'Live trip tracking with real-time ETA',
        'Pre-trip checklist and pool group chat',
        'Wallet with cashback and referral rewards',
        'Route optimizer for operators',
        'Full CHIP payment integration',
      ],
    },
  ];

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
                          color: AeroColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APP VERSION',
                        style: TextStyle(
                          fontSize: 11,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'What\'s new',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AeroColors.amber,
                            AeroColors.amber.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.system_update_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'AeroCrew v1.0.0',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'You\'re on the latest version',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...changelog.map(
                      (v) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AeroColors.navyCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: v['isLatest'] == true
                                ? AeroColors.amber.withValues(alpha: 0.3)
                                : AeroColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'v${v['version']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                if (v['isLatest'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AeroColors.amber,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'LATEST',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              v['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...(v['changes'] as List).map(
                              (change) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AeroColors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        change.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
