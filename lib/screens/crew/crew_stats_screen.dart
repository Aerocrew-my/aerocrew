import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class CrewStatsScreen extends StatefulWidget {
  const CrewStatsScreen({super.key});

  @override
  State<CrewStatsScreen> createState() => _CrewStatsScreenState();
}

class _CrewStatsScreenState extends State<CrewStatsScreen> {
  String selectedPeriod = '6M';

  final periods = ['1M', '3M', '6M', '1Y', 'All'];

  final monthlyTrips = [12, 18, 14, 20, 16, 22];
  final monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  final achievements = [
    {
      'icon': Icons.local_fire_department,
      'title': '10-trip streak',
      'desc': '10 flights in a row without late pickup',
      'color': Color(0xFFEF9F27),
      'earned': true,
    },
    {
      'icon': Icons.star,
      'title': 'Top crew member',
      'desc': 'Rated 5 stars by operators 5 times',
      'color': Color(0xFFBA7517),
      'earned': true,
    },
    {
      'icon': Icons.people,
      'title': 'Social crew',
      'desc': 'Referred 3 crew members to AeroCrew',
      'color': Color(0xFF1D9E75),
      'earned': false,
    },
    {
      'icon': Icons.flight,
      'title': 'Frequent flyer',
      'desc': '50 trips completed with AeroCrew',
      'color': Color(0xFF378ADD),
      'earned': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 20),
                    _buildTripChart(),
                    const SizedBox(height: 20),
                    _buildSavingsCard(),
                    const SizedBox(height: 20),
                    _buildAchievements(),
                    const SizedBox(height: 20),
                    _buildAirlineBreakdown(),
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
              Text('MY STATS',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Your AeroCrew journey',
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

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total trips', '102', Icons.flight, AeroColors.amber),
        _buildStatCard(
            'On time', '98%', Icons.check_circle_outline, AeroColors.success),
        _buildStatCard('Avg rating', '4.9', Icons.star, const Color(0xFFEF9F27)),
        _buildStatCard('Money saved', 'RM4,200',
            Icons.savings_outlined, AeroColors.infoText),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AeroColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripChart() {
    final maxTrips =
        monthlyTrips.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('TRIPS PER MONTH', style: AeroText.label),
              const Spacer(),
              Row(
                children: periods.map((p) {
                  final isSelected = selectedPeriod == p;
                  return GestureDetector(
                    onTap: () => setState(() => selectedPeriod = p),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AeroColors.amber
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(p,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AeroColors.grey)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyTrips.asMap().entries.map((e) {
                final ratio = e.value / maxTrips;
                final isLast = e.key == monthlyTrips.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLast)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text('${e.value}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AeroColors.amber)),
                          ),
                        Flexible(
                          flex: (ratio * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AeroColors.amber
                                  : AeroColors.amber.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5)),
                            ),
                          ),
                        ),
                        Flexible(
                          flex:
                              ((1 - ratio) * 100).toInt().clamp(1, 100),
                          child: const SizedBox(),
                        ),
                        const SizedBox(height: 6),
                        Text(monthLabels[e.key],
                            style: TextStyle(
                                fontSize: 10,
                                color: isLast
                                    ? AeroColors.amber
                                    : AeroColors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.success.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SAVINGS VS GRAB', style: AeroText.label),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('You paid',
                        style: TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                    Text('RM7,650',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('with AeroCrew',
                        style: TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward,
                  color: AeroColors.grey, size: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Grab would cost',
                        style: TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                    Text('RM11,850',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.danger)),
                    Text('estimated',
                        style: TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings, color: AeroColors.success, size: 18),
                SizedBox(width: 8),
                Text('You saved RM4,200 with AeroCrew!',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACHIEVEMENTS', style: AeroText.label),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: achievements.map((a) {
            final earned = a['earned'] as bool;
            final color = a['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: earned
                    ? color.withValues(alpha: 0.08)
                    : AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: earned
                      ? color.withValues(alpha: 0.3)
                      : AeroColors.divider,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(a['icon'] as IconData,
                      color: earned ? color : AeroColors.divider,
                      size: 22),
                  const Spacer(),
                  Text(a['title'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: earned ? Colors.white : AeroColors.grey)),
                  Text(a['desc'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: AeroColors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAirlineBreakdown() {
    final airlines = [
      {'name': 'AirAsia', 'trips': 68, 'color': const Color(0xFFBA7517)},
      {'name': 'Malaysia Airlines', 'trips': 22, 'color': const Color(0xFF378ADD)},
      {'name': 'Batik Air', 'trips': 12, 'color': const Color(0xFF1D9E75)},
    ];
    final total = airlines.fold(0, (s, a) => s + (a['trips'] as int));

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
          const Text('TRIPS BY AIRLINE', style: AeroText.label),
          const SizedBox(height: 12),
          ...airlines.map((a) {
            final ratio = (a['trips'] as int) / total;
            final color = a['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(a['name'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: AeroColors.greyLight)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${a['trips']}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}