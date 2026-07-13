import 'package:flutter/material.dart';
import 'package:aerocrew/screens/crew/crew_profile_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  String selectedProduct = 'aeropool';
  bool isLoading = false;

  final products = [
    {
      'id': 'aeropool',
      'name': 'AeroPool',
      'tagline': 'Shared · Monthly subscription',
      'price': 'From RM300',
      'period': '/month',
      'color': Color(0xFFBA7517),
      'bgColor': Color(0xFF1C1608),
      'borderColor': Color(0xFFBA7517),
      'badge': 'Most popular',
      'icon': Icons.people,
      'features': [
        'AI-matched car-pooling',
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
      'bgColor': Color(0xFF081422),
      'borderColor': Color(0xFF2A3347),
      'badge': '',
      'icon': Icons.bolt,
      'features': [
        'No monthly commitment',
        'Book anytime',
        'Ideal for standby crew',
      ],
    },
    {
      'id': 'aerosolo',
      'name': 'AeroSolo',
      'tagline': 'Private · Dedicated vehicle',
      'price': 'From RM800',
      'period': '/month',
      'color': Color(0xFFEF9F27),
      'bgColor': Color(0xFF1A1200),
      'borderColor': Color(0xFF2A3347),
      'badge': 'Premium',
      'icon': Icons.star,
      'features': ['Non sharing', 'Sedan & MPV', 'Priority matching'],
    },
  ];

  Future<void> _selectProduct() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'product': selectedProduct,
        'productSelectedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CrewProfileScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = products.firstWhere((p) => p['id'] == selectedProduct);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.aero.blueSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_taxi,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 2 OF 3',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Choose your plan',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Transport that\nfits your schedule.',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'You can change this anytime.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.aero.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ...products.map((product) {
                          final isSelected = selectedProduct == product['id'];
                          final color = product['color'] as Color;
                          final features = product['features'] as List<String>;
                          final badge = product['badge'] as String;

                          return GestureDetector(
                            onTap: () => setState(
                              () => selectedProduct = product['id'] as String,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.08)
                                    : context.aero.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : context.aero.border,
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
                                          color: color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          product['icon'] as IconData,
                                          color: color,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                          Text(
                                            product['tagline'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: context.aero.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      if (badge.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            badge,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        product['price'] as String,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        product['period'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.aero.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: 12),
                                    Divider(
                                      color: context.aero.border,
                                      height: 1,
                                    ),
                                    const SizedBox(height: 10),
                                    ...features.map(
                                      (f) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: color,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              f,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    theme.colorScheme.onSurface,
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
                            onPressed: isLoading ? null : _selectProduct,
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue with ${(selected['name'] as String)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 18),
                                    ],
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
        ],
      ),
    );
  }
}
