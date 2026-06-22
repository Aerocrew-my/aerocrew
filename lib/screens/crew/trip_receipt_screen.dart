import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class TripReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripReceiptScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildReceiptCard(),
                    const SizedBox(height: 16),
                    _buildActions(context),
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
    return Container(
      color: AeroColors.navy,
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
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRIP RECEIPT',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Payment summary',
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

  Widget _buildReceiptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AeroColors.navy,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AeroColors.amber,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.flight,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('AeroCrew',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AeroColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('PAID',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AeroColors.success,
                              letterSpacing: 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                    'RM${(trip['fare'] ?? 75.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(
                    '${trip['flight'] ?? 'AK6101'} · ${trip['date'] ?? 'Mon 16 Jun 2026'}',
                    style: const TextStyle(
                        fontSize: 13, color: AeroColors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildReceiptRow('Trip route',
                    '${trip['zone'] ?? 'PJ'} → ${trip['airport'] ?? 'SZB'}'),
                _buildDivider(),
                _buildReceiptRow('Pickup time',
                    trip['pickupTime'] as String? ?? '03:00'),
                _buildReceiptRow('Arrival time', '04:15'),
                _buildReceiptRow('Driver', 'Ahmad Hassan'),
                _buildReceiptRow('Vehicle', 'Toyota Hiace · WXY 1234'),
                _buildDivider(),
                _buildReceiptRow('Product', 'AeroPool'),
                _buildReceiptRow('Poolmates', '2 crew'),
                _buildDivider(),
                _buildReceiptRow('Base fare', 'RM65.00'),
                _buildReceiptRow('Toll & surcharge', 'RM10.00'),
                _buildDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.navy)),
                    Text(
                        'RM${(trip['fare'] ?? 75.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AeroColors.navy)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AeroColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment method',
                          style: TextStyle(
                              fontSize: 12, color: AeroColors.grey)),
                      const Text('AeroPool Subscription',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AeroColors.navy)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaction ID',
                        style: TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                    Text(
                        'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AeroColors.grey,
                            fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                30,
                (i) => Expanded(
                  child: Container(
                    height: 2,
                    color: i.isEven
                        ? AeroColors.cardBorder
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Thank you for flying with AeroCrew!',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AeroColors.navy),
                ),
                const SizedBox(height: 4),
                const Text('aerocrew.my',
                    style: TextStyle(
                        fontSize: 12, color: AeroColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AeroColors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AeroColors.navy)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AeroColors.cardBorder, height: 1),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download PDF receipt',
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
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Share receipt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AeroColors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side:
                  const BorderSide(color: AeroColors.amber, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}