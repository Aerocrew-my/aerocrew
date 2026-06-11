import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final crew = job['crew'] as List<dynamic>;
    final isConfirmed = job['status'] == 'confirmed';

    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTripSummary(),
                    const SizedBox(height: 20),
                    if (crew.isNotEmpty) ...[
                      _buildPickupRoute(crew),
                      const SizedBox(height: 20),
                    ],
                    _buildEarningsCard(),
                    const SizedBox(height: 20),
                    _buildActionButtons(context, isConfirmed),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Text('JOB DETAILS',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Pickup route',
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

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.success.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AeroColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flight_takeoff,
                color: AeroColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${job['date']} · Flight ${job['flightTime']} ${job['airport']}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 3),
                Text(
                    'Pickup starts ${job['pickupTime']} · ${job['crewCount']} passengers',
                    style: const TextStyle(
                        fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupRoute(List<dynamic> crew) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PICKUP ROUTE',
            style: TextStyle(
                fontSize: 11,
                color: AeroColors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        ...List.generate(crew.length, (i) {
          final member = crew[i] as Map<String, dynamic>;
          final isLast = i == crew.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AeroColors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: AeroColors.divider,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AeroColors.navyCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AeroColors.divider, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['name'] as String,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            Text(member['zone'] as String,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AeroColors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AeroColors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(member['time'] as String,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AeroColors.amber)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ESTIMATED EARNINGS',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                SizedBox(height: 4),
                Text('After 15% AeroCrew commission',
                    style:
                        TextStyle(fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Text(
              'RM${(job['earnings'] as double).toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AeroColors.amber)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isConfirmed) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.navigation_outlined, size: 18),
            label: const Text('Start navigation',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AeroColors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to dashboard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AeroColors.greyLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side:
                  const BorderSide(color: AeroColors.divider, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}