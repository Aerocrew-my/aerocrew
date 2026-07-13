import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String selectedMonth = 'June 2026';

  final months = ['June 2026', 'May 2026', 'April 2026'];

  final List<Map<String, dynamic>> transactions = [
    {
      'date': 'Mon 16 Jun',
      'route': 'PJ → SZB',
      'crew': 3,
      'gross': 270.0,
      'commission': 40.5,
      'net': 229.5,
      'product': 'AeroPool',
    },
    {
      'date': 'Mon 16 Jun',
      'route': 'Shah Alam → KLIA',
      'crew': 2,
      'gross': 220.0,
      'commission': 33.0,
      'net': 187.0,
      'product': 'AeroPool',
    },
    {
      'date': 'Tue 17 Jun',
      'route': 'Damansara → KLIA',
      'crew': 4,
      'gross': 360.0,
      'commission': 54.0,
      'net': 306.0,
      'product': 'AeroPool',
    },
    {
      'date': 'Wed 18 Jun',
      'route': 'Cyberjaya → klia2',
      'crew': 2,
      'gross': 140.0,
      'commission': 28.0,
      'net': 112.0,
      'product': 'AeroFlex',
    },
  ];

  double get totalGross =>
      transactions.fold(0.0, (s, t) => s + (t['gross'] as double));
  double get totalCommission =>
      transactions.fold(0.0, (s, t) => s + (t['commission'] as double));
  double get totalNet =>
      transactions.fold(0.0, (s, t) => s + (t['net'] as double));

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EARNINGS',
                          style: TextStyle(
                            fontSize: 11,
                            color: AeroColors.amber,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Income breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AeroColors.navyCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AeroColors.divider, width: 0.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        isDense: true,
                        dropdownColor: AeroColors.navyCard,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AeroColors.grey,
                          size: 16,
                        ),
                        items: months
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedMonth = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AeroColors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AeroColors.amber.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'NET EARNINGS',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AeroColors.amber,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                selectedMonth,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AeroColors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'RM${totalNet.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AeroColors.amber,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox(
                                  'Gross',
                                  'RM${totalGross.toStringAsFixed(0)}',
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatBox(
                                  'Commission (15%)',
                                  '−RM${totalCommission.toStringAsFixed(0)}',
                                  AeroColors.danger,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatBox(
                                  'Trips',
                                  '${transactions.length}',
                                  AeroColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('TRANSACTION DETAILS', style: AeroText.label),
                    const SizedBox(height: 10),
                    ...transactions.map(
                      (t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AeroColors.navyCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AeroColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AeroColors.navy,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AeroColors.divider,
                                  width: 0.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${t['crew']}px',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['route'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    t['date'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'RM${(t['net'] as double).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AeroColors.amber,
                                  ),
                                ),
                                Text(
                                  '−RM${(t['commission'] as double).toStringAsFixed(0)} fee',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AeroColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AeroColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: AeroColors.grey,
                            size: 16,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Earnings are paid out every Monday via bank transfer. Commission is 15% for AeroPool and 20% for AeroFlex.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AeroColors.grey,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AeroColors.navy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AeroColors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
