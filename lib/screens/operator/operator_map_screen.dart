import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorMapScreen extends StatelessWidget {
  const OperatorMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      appBar: AppBar(
        backgroundColor: AeroColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Live Map',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AeroColors.navyCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AeroColors.divider, width: 0.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: AeroColors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Operator Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Live route optimization and crew tracking\nwill appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AeroColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AeroColors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AeroColors.amber.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AeroColors.amber, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Phase 2: Live driver location, pickup sequencing, crew ETAs and route optimization.',
                      style: TextStyle(color: AeroColors.amber, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
