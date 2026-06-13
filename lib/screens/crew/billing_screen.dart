import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/subscription_screen.dart';
import 'package:aerocrew/screens/crew/change_plan_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;

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
        setState(() {
          userData = doc.data() ?? {};
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String get plan => userData['product'] ?? 'aeropool';

  String get planName {
    switch (plan) {
      case 'aeroflex': return 'AeroFlex';
      case 'aerosolo': return 'AeroSolo';
      default: return 'AeroPool';
    }
  }

  Color get planColor {
    switch (plan) {
      case 'aeroflex': return const Color(0xFF378ADD);
      case 'aerosolo': return const Color(0xFFEF9F27);
      default: return AeroColors.amber;
    }
  }

  double get planPrice {
    switch (plan) {
      case 'aeroflex': return 0;
      case 'aerosolo': return 1500;
      default: return 750;
    }
  }

  final List<Map<String, dynamic>> paymentHistory = [
    {
      'month': 'June 2026',
      'amount': 750.0,
      'status': 'paid',
      'method': 'FPX Maybank',
      'date': '1 Jun 2026',
      'ref': 'AEROCREW-A1B2C3D4-001',
    },
    {
      'month': 'May 2026',
      'amount': 750.0,
      'status': 'paid',
      'method': 'FPX Maybank',
      'date': '1 May 2026',
      'ref': 'AEROCREW-A1B2C3D4-002',
    },
    {
      'month': 'April 2026',
      'amount': 750.0,
      'status': 'paid',
      'method': 'Touch \'n Go',
      'date': '1 Apr 2026',
      'ref': 'AEROCREW-A1B2C3D4-003',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AeroColors.amber))
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildActiveSubscription(),
                          const SizedBox(height: 16),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          const Text('PAYMENT HISTORY',
                              style: AeroText.label),
                          const SizedBox(height: 10),
                          ...paymentHistory.map(_buildPaymentRow),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BILLING',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Subscription & payments',
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

  Widget _buildActiveSubscription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [planColor, planColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                plan == 'aeroflex'
                    ? Icons.bolt
                    : plan == 'aerosolo'
                        ? Icons.star
                        : Icons.people,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(planName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          plan == 'aeroflex'
              ? const Text('Pay per trip',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white))
              : Text(
                  'RM${planPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
          if (plan != 'aeroflex')
            const Text('per month',
                style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next renewal',
                        style: TextStyle(
                            fontSize: 11, color: Colors.white70)),
                    const Text('1 Jul 2026',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Zone',
                        style: TextStyle(
                            fontSize: 11, color: Colors.white70)),
                    Text(userData['homeZone'] ?? '—',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChangePlanScreen())),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.swap_horiz,
                      color: AeroColors.amber, size: 22),
                  SizedBox(height: 6),
                  Text('Change plan',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SubscriptionScreen(plan: plan))),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.refresh, color: AeroColors.success, size: 22),
                  SizedBox(height: 6),
                  Text('Renew now',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.dangerLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AeroColors.danger.withOpacity(0.2), width: 0.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cancel_outlined,
                      color: AeroColors.danger, size: 22),
                  SizedBox(height: 6),
                  Text('Cancel',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AeroColors.danger)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AeroColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long,
                color: AeroColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment['month'] as String,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text('${payment['method']} · ${payment['date']}',
                    style: const TextStyle(
                        fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  'RM${(payment['amount'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AeroColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Paid',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.success,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}