import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  String selectedFilter = 'all';

  final List<Map<String, dynamic>> trips = [
    {
      'flight': 'AK6101',
      'date': 'Mon 16 Jun 2026',
      'route': 'Petaling Jaya → SZB',
      'operator': 'Ahmad Hassan',
      'vehicle': 'Toyota Hiace',
      'fare': 75.0,
      'product': 'AeroPool',
      'status': 'completed',
      'rating': 5,
    },
    {
      'flight': 'AK6204',
      'date': 'Wed 18 Jun 2026',
      'route': 'Petaling Jaya → SZB',
      'operator': 'Rahman Drivers',
      'vehicle': 'Toyota Alphard',
      'fare': 85.0,
      'product': 'AeroPool',
      'status': 'completed',
      'rating': 4,
    },
    {
      'flight': 'AK6310',
      'date': 'Fri 20 Jun 2026',
      'route': 'Petaling Jaya → SZB',
      'operator': 'Ahmad Hassan',
      'vehicle': 'Toyota Hiace',
      'fare': 75.0,
      'product': 'AeroPool',
      'status': 'completed',
      'rating': 0,
    },
    {
      'flight': 'AK5501',
      'date': 'Sun 8 Jun 2026',
      'route': 'Petaling Jaya → KLIA',
      'operator': 'Rahman Drivers',
      'vehicle': 'Toyota Alphard',
      'fare': 120.0,
      'product': 'AeroFlex',
      'status': 'completed',
      'rating': 5,
    },
  ];

  List<Map<String, dynamic>> get filtered {
    if (selectedFilter == 'all') return trips;
    return trips
        .where(
          (t) =>
              (t['product'] as String).toLowerCase().contains(selectedFilter),
        )
        .toList();
  }

  Color productColor(String product) {
    if (product == 'AeroFlex') return const Color(0xFF378ADD);
    if (product == 'AeroSolo') return const Color(0xFFEF9F27);
    return AeroColors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = trips.fold(0.0, (sum, t) => sum + (t['fare'] as double));

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
                        'TRIP HISTORY',
                        style: TextStyle(
                          fontSize: 11,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'All your trips',
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AeroColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL TRIPS',
                            style: TextStyle(
                              fontSize: 10,
                              color: AeroColors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trips.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AeroColors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AeroColors.amber.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL SAVED',
                            style: TextStyle(
                              fontSize: 10,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RM${(trips.length * 90 - totalSpent).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AeroColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilter('all', 'All trips'),
                  const SizedBox(width: 8),
                  _buildFilter('aeropool', 'AeroPool'),
                  const SizedBox(width: 8),
                  _buildFilter('aeroflex', 'AeroFlex'),
                  const SizedBox(width: 8),
                  _buildFilter('aerosolo', 'AeroSolo'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final trip = filtered[i];
                  final color = productColor(trip['product'] as String);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AeroColors.navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AeroColors.divider, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                trip['product'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'RM${(trip['fare'] as double).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AeroColors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${trip['flight']} · ${trip['date']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          trip['route'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AeroColors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AeroColors.amberLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                size: 14,
                                color: AeroColors.amber,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${trip['operator']} · ${trip['vehicle']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AeroColors.greyLight,
                                ),
                              ),
                            ),
                            if ((trip['rating'] as int) > 0)
                              Row(
                                children: List.generate(
                                  5,
                                  (s) => Icon(
                                    Icons.star,
                                    size: 12,
                                    color: s < (trip['rating'] as int)
                                        ? AeroColors.amber
                                        : AeroColors.divider,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AeroColors.amber.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Rate trip',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AeroColors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  Widget _buildFilter(String id, String label) {
    final isSelected = selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AeroColors.amber : AeroColors.navyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AeroColors.amber : AeroColors.divider,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AeroColors.grey,
          ),
        ),
      ),
    );
  }
}
