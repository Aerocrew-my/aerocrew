import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/config/app_config.dart';
import 'package:aerocrew/services/chip_service.dart';
import 'package:aerocrew/screens/shared/payment_webview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionScreen extends StatefulWidget {
  final String plan;
  const SubscriptionScreen({super.key, required this.plan});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() => userData = doc.data() ?? {});
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  double get price {
    if (widget.plan == 'aeroflex') return 0;
    final zone = userData['homeZone'] ?? '';
    if (widget.plan == 'aeropool') {
      return ChipService.getPriceForZone(zone);
    }
    // AeroSolo
    final zonePrice = ChipService.getPriceForZone(zone);
    return zonePrice * 2; // Solo is roughly 2x pool
  }

  String get planName =>
      AppConfig.plans[widget.plan]?['name'] as String? ?? 'AeroPool';

  Color get planColor =>
      Color(AppConfig.plans[widget.plan]?['color'] as int? ?? 0xFFBA7517);

  String get planDesc =>
      AppConfig.plans[widget.plan]?['description'] as String? ?? '';

  Future<void> _startPayment() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final reference = 'AEROCREW-${uid.substring(0, 8).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

      final result = await ChipService.createPurchase(
        email: userData['email'] ?? '',
        name: userData['name'] ?? 'AeroCrew User',
        phone: userData['phone'] ?? '',
        amount: price,
        description: '$planName Monthly Subscription',
        reference: reference,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebviewScreen(
              checkoutUrl: result['checkoutUrl'],
              amount: price,
              plan: planName,
              transactionId: reference,
            ),
          ),
        );
      } else {
        // Demo mode — CHIP not configured yet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebviewScreen(
              checkoutUrl:
                  'https://gate.chip-in.asia/p/demo/',
              amount: price,
              plan: planName,
              transactionId: reference,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => errorMessage = 'Something went wrong. Please try again.');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanCard(),
                    const SizedBox(height: 20),
                    _buildPriceBreakdown(),
                    const SizedBox(height: 20),
                    _buildWhatYouGet(),
                    const SizedBox(height: 20),
                    _buildPaymentMethods(),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AeroColors.dangerLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AeroColors.danger.withOpacity(0.3)),
                        ),
                        child: Text(errorMessage!,
                            style: const TextStyle(
                                fontSize: 12, color: AeroColors.danger)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildSubscribeButton(),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Cancel anytime · No hidden fees · SSL secured',
                        style: TextStyle(
                            fontSize: 11, color: AeroColors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SUBSCRIBE',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text(planName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: planColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: planColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: planColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.plan == 'aeroflex'
                  ? Icons.bolt
                  : widget.plan == 'aerosolo'
                      ? Icons.star
                      : Icons.people,
              color: planColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planName,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: planColor)),
                Text(planDesc,
                    style: const TextStyle(
                        fontSize: 12, color: AeroColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final zone = userData['homeZone'] ?? 'your zone';
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
          const Text('PRICE BREAKDOWN',
              style: AeroText.label),
          const SizedBox(height: 12),
          _buildPriceRow('Zone', zone),
          _buildPriceRow('Billing cycle', 'Monthly'),
          _buildPriceRow('Coverage', 'SZB · KLIA · klia2'),
          const Divider(color: AeroColors.divider, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total per month',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('RM${price.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: planColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                  color: AeroColors.greyLight)),
        ],
      ),
    );
  }

  Widget _buildWhatYouGet() {
    final features = widget.plan == 'aeroflex'
        ? [
            'Book any trip on demand',
            'No monthly commitment',
            'Ideal for standby & relief duties',
            'Verified operators only',
          ]
        : widget.plan == 'aerosolo'
            ? [
                'Private dedicated vehicle',
                'No sharing with other crew',
                'Sedan, MPV, Alphard available',
                'Priority matching',
                'Guaranteed pickup every trip',
              ]
            : [
                'AI-matched van pooling',
                'Guaranteed seat every trip',
                'Zone-based efficient routing',
                'Up to 8 crew per van',
                'Verified PSV operators',
                'Advance scheduling from roster',
              ];

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
          const Text("WHAT YOU GET", style: AeroText.label),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 14, color: planColor),
                    const SizedBox(width: 10),
                    Text(f,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AeroColors.greyLight)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
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
          const Text('PAYMENT METHODS', style: AeroText.label),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'FPX Online Banking',
              'Visa / Mastercard',
              'Touch \'n Go',
              'Boost',
              'GrabPay',
              'Maybank QR',
            ].map((method) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AeroColors.navy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AeroColors.divider, width: 0.5),
                  ),
                  child: Text(method,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AeroColors.greyLight)),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: planColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                widget.plan == 'aeroflex'
                    ? 'Continue with AeroFlex'
                    : 'Subscribe for RM${price.toStringAsFixed(0)}/month',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}