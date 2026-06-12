import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorTripHistoryScreen extends StatelessWidget {
  const OperatorTripHistoryScreen({super.key});

  final List<Map<String, dynamic>> trips = const [
    {
      'date': 'Mon 16 Jun 2026',
      'route': 'PJ → SZB',
      'crew': 3,
      'earnings': 229.5,
      'rating': 5,
    },
    {
      'date': 'Mon 16 Jun 2026',
      'route': 'Shah Alam → KLIA',
      'crew': 2,
      'earnings': 187.0,
      'rating': 4,
    },
    {
      'date': 'Tue 17 Jun 2026',
      'route': 'Damansara → KLIA',
      'crew': 4,
      'earnings': 306.0,
      'rating': 5,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                      Text('TRIP HISTORY',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('Completed jobs',
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: trips.length,
                itemBuilder: (context, i) {
                  final trip = trips[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AeroColors.navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AeroColors.divider, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AeroColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              color: AeroColors.success, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(trip['route'] as String,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              Text(
                                  '${trip['date']} · ${trip['crew']} crew',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (s) => Icon(Icons.star,
                                      size: 11,
                                      color: s < (trip['rating'] as int)
                                          ? AeroColors.amber
                                          : AeroColors.divider),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                            'RM${(trip['earnings'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AeroColors.amber)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}