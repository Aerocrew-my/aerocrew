import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorStatsScreen extends StatelessWidget {
  const OperatorStatsScreen({super.key});

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
                    _buildOverview(),
                    const SizedBox(height: 20),
                    _buildPerformanceCard(),
                    const SizedBox(height: 20),
                    _buildMonthlyChart(),
                    const SizedBox(height: 20),
                    _buildRankCard(),
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
                'MY PERFORMANCE',
                style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Operator stats',
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
    );
  }

  Widget _buildOverview() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatTile(
          'Total trips',
          '87',
          Icons.directions_car,
          AeroColors.amber,
        ),
        _buildStatTile(
          'Avg rating',
          '4.9',
          Icons.star,
          const Color(0xFFEF9F27),
        ),
        _buildStatTile(
          'On-time',
          '98%',
          Icons.check_circle_outline,
          AeroColors.success,
        ),
        _buildStatTile(
          'Total earned',
          'RM7,830',
          Icons.payments_outlined,
          AeroColors.infoText,
        ),
      ],
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AeroColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    final metrics = [
      {'label': 'Pickup on time', 'value': 98, 'color': AeroColors.success},
      {'label': 'No cancellations', 'value': 100, 'color': AeroColors.success},
      {'label': 'Crew satisfaction', 'value': 96, 'color': AeroColors.amber},
      {'label': 'Route efficiency', 'value': 92, 'color': AeroColors.infoText},
    ];

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
          const Text('PERFORMANCE METRICS', style: AeroText.label),
          const SizedBox(height: 12),
          ...metrics.map((m) {
            final color = m['color'] as Color;
            final value = m['value'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AeroColors.greyLight,
                        ),
                      ),
                      Text(
                        '$value%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final data = [14, 18, 12, 20, 16, 22, 87];
    final labels = ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();

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
          const Text('MONTHLY TRIPS', style: AeroText.label),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((e) {
                final ratio = e.value / maxVal;
                final isLast = e.key == data.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLast)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '${e.value}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AeroColors.amber,
                              ),
                            ),
                          ),
                        Flexible(
                          flex: (ratio * 100).toInt().clamp(1, 100),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AeroColors.amber
                                  : AeroColors.amber.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: ((1 - ratio) * 100).toInt().clamp(1, 100),
                          child: const SizedBox(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labels[e.key],
                          style: TextStyle(
                            fontSize: 10,
                            color: isLast ? AeroColors.amber : AeroColors.grey,
                          ),
                        ),
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

  Widget _buildRankCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1200), Color(0xFF2A1F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEF9F27).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text('🥇', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            'Top operator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEF9F27),
            ),
          ),
          const Text(
            'Ranked #1 in Petaling Jaya zone',
            style: TextStyle(fontSize: 12, color: AeroColors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRankStat('87', 'Trips'),
              _buildRankStat('4.9★', 'Rating'),
              _buildRankStat('98%', 'On-time'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEF9F27),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AeroColors.grey),
        ),
      ],
    );
  }
}
