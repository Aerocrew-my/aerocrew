import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorEarningsAnalyticsScreen extends StatefulWidget {
  const OperatorEarningsAnalyticsScreen({super.key});

  @override
  State<OperatorEarningsAnalyticsScreen> createState() =>
      _OperatorEarningsAnalyticsScreenState();
}

class _OperatorEarningsAnalyticsScreenState
    extends State<OperatorEarningsAnalyticsScreen> {
  String selectedPeriod = 'month';

  final List<Map<String, dynamic>> weeklyData = [
    {'week': 'W1', 'earnings': 860.0, 'trips': 12, 'crew': 28},
    {'week': 'W2', 'earnings': 1020.0, 'trips': 14, 'crew': 34},
    {'week': 'W3', 'earnings': 780.0, 'trips': 11, 'crew': 24},
    {'week': 'W4', 'earnings': 1175.0, 'trips': 16, 'crew': 42},
  ];

  final List<Map<String, dynamic>> monthlyData = [
    {'month': 'Jan', 'earnings': 2800.0},
    {'month': 'Feb', 'earnings': 3200.0},
    {'month': 'Mar', 'earnings': 2950.0},
    {'month': 'Apr', 'earnings': 3800.0},
    {'month': 'May', 'earnings': 4100.0},
    {'month': 'Jun', 'earnings': 3835.0},
  ];

  final List<Map<String, dynamic>> topRoutes = [
    {'route': 'PJ → SZB', 'trips': 24, 'earnings': 1080.0},
    {'route': 'Shah Alam → KLIA', 'trips': 18, 'earnings': 1260.0},
    {'route': 'Damansara → KLIA', 'trips': 14, 'earnings': 1120.0},
    {'route': 'Cyberjaya → klia2', 'trips': 10, 'earnings': 600.0},
    {'route': 'Subang → SZB', 'trips': 8, 'earnings': 400.0},
  ];

  double get totalEarnings =>
      monthlyData.fold(0, (s, m) => s + (m['earnings'] as double));
  double get thisMonthEarnings => monthlyData.last['earnings'] as double;
  double get maxEarnings =>
      monthlyData.map((m) => m['earnings'] as double).reduce((a, b) => a > b ? a : b);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopStats(),
                    const SizedBox(height: 20),
                    _buildBarChart(),
                    const SizedBox(height: 20),
                    _buildWeeklyBreakdown(),
                    const SizedBox(height: 20),
                    _buildTopRoutes(),
                    const SizedBox(height: 20),
                    _buildPayoutInfo(),
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
              Text('EARNINGS ANALYTICS',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Income overview',
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

  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AeroColors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AeroColors.amber.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THIS MONTH',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.amber,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Text('RM${thisMonthEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.amber)),
                const Text('after 15% commission',
                    style: TextStyle(fontSize: 10, color: AeroColors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YTD TOTAL',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Text('RM${totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const Text('year to date',
                    style: TextStyle(fontSize: 10, color: AeroColors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
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
          const Text('MONTHLY EARNINGS',
              style: AeroText.label),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((m) {
                final earnings = m['earnings'] as double;
                final ratio = earnings / maxEarnings;
                final isLast = m == monthlyData.last;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLast)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                                'RM${(earnings / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: AeroColors.amber,
                                    fontWeight: FontWeight.w600)),
                          ),
                        Flexible(
                          flex: (ratio * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AeroColors.amber
                                  : AeroColors.amber.withOpacity(0.3),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: ((1 - ratio) * 100).toInt(),
                          child: const SizedBox(),
                        ),
                        const SizedBox(height: 6),
                        Text(m['month'] as String,
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

  Widget _buildWeeklyBreakdown() {
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
          const Text('JUNE WEEKLY BREAKDOWN',
              style: AeroText.label),
          const SizedBox(height: 12),
          ...weeklyData.map((w) {
            final earnings = w['earnings'] as double;
            final maxW = weeklyData
                .map((d) => d['earnings'] as double)
                .reduce((a, b) => a > b ? a : b);
            final ratio = earnings / maxW;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(w['week'] as String,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AeroColors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor:
                                AeroColors.amber.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AeroColors.amber),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                            '${w['trips']} trips · ${w['crew']} crew',
                            style: const TextStyle(
                                fontSize: 10, color: AeroColors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('RM${earnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 12,
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

  Widget _buildTopRoutes() {
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
          const Text('TOP ROUTES THIS MONTH',
              style: AeroText.label),
          const SizedBox(height: 12),
          ...topRoutes.asMap().entries.map((entry) {
            final i = entry.key;
            final route = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AeroColors.navy,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? AeroColors.amber
                          : AeroColors.navyCard,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: i == 0
                                  ? Colors.white
                                  : AeroColors.grey)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route['route'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text('${route['trips']} trips',
                            style: const TextStyle(
                                fontSize: 10, color: AeroColors.grey)),
                      ],
                    ),
                  ),
                  Text(
                      'RM${(route['earnings'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.amber)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPayoutInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.success.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_outlined,
                  color: AeroColors.success, size: 18),
              SizedBox(width: 8),
              Text('PAYOUT SCHEDULE',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.success,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          _buildPayoutRow('Next payout', 'Mon 23 Jun 2026'),
          _buildPayoutRow('Amount', 'RM${(thisMonthEarnings * 0.6).toStringAsFixed(0)} (partial)'),
          _buildPayoutRow('Bank', 'Registered bank account'),
          _buildPayoutRow('Frequency', 'Every Monday'),
        ],
      ),
    );
  }

  Widget _buildPayoutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AeroColors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}