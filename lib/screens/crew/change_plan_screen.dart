import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/subscription_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePlanScreen extends StatefulWidget {
  const ChangePlanScreen({super.key});

  @override
  State<ChangePlanScreen> createState() => _ChangePlanScreenState();
}

class _ChangePlanScreenState extends State<ChangePlanScreen> {
  String currentPlan = 'aeropool';
  String selectedPlan = 'aeropool';
  bool isLoading = false;

  final plans = [
    {
      'id': 'aeropool',
      'name': 'AeroPool',
      'tagline': 'Shared · Monthly',
      'price': 'From RM300',
      'period': '/month',
      'color': Color(0xFFBA7517),
      'icon': Icons.people,
      'badge': 'Most popular',
      'features': [
        'AI-matched pooling',
        'Guaranteed seat',
        'Zone-based routing',
      ],
    },
    {
      'id': 'aeroflex',
      'name': 'AeroFlex',
      'tagline': 'Pay per trip · Ad-hoc',
      'price': 'From RM35',
      'period': '/trip',
      'color': Color(0xFF378ADD),
      'icon': Icons.bolt,
      'badge': '',
      'features': [
        'No monthly commitment',
        'Book anytime',
        'Ideal for standby crew',
      ],
    },
    {
      'id': 'aerosolo',
      'name': 'AeroSolo',
      'tagline': 'Private · Dedicated',
      'price': 'From RM800',
      'period': '/month',
      'color': Color(0xFFEF9F27),
      'icon': Icons.star,
      'badge': 'Premium',
      'features': ['No sharing', 'Sedan, MPV or Alphard', 'Priority matching'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          currentPlan = doc.data()?['product'] ?? 'aeropool';
          selectedPlan = currentPlan;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = plans.firstWhere((p) => p['id'] == selectedPlan);
    final color = selected['color'] as Color;
    final isCurrentPlan = selectedPlan == currentPlan;

    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'CHANGE PLAN',
                        style: TextStyle(
                          fontSize: 11,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Choose your transport plan',
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
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ...plans.map((plan) {
                      final isSelected = selectedPlan == plan['id'];
                      final isCurrent = plan['id'] == currentPlan;
                      final planColor = plan['color'] as Color;
                      final features = plan['features'] as List<String>;
                      final badge = plan['badge'] as String;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedPlan = plan['id'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? planColor.withValues(alpha: 0.08)
                                : AeroColors.navyCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? planColor
                                  : AeroColors.divider,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: planColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      plan['icon'] as IconData,
                                      color: planColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan['name'] as String,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: planColor,
                                        ),
                                      ),
                                      Text(
                                        plan['tagline'] as String,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AeroColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AeroColors.success.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Current',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AeroColors.success,
                                        ),
                                      ),
                                    )
                                  else if (badge.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: planColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        badge,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: planColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    plan['price'] as String,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    plan['period'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 10),
                                const Divider(
                                  color: AeroColors.divider,
                                  height: 1,
                                ),
                                const SizedBox(height: 8),
                                ...features.map(
                                  (f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 13,
                                          color: planColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          f,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AeroColors.greyLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isCurrentPlan || isLoading
                            ? null
                            : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SubscriptionScreen(plan: selectedPlan),
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AeroColors.navyCard,
                          disabledForegroundColor: AeroColors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isCurrentPlan
                              ? 'Current plan'
                              : 'Switch to ${selected['name']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
