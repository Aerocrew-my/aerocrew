import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/edit_profile_screen.dart';
import 'package:aerocrew/screens/crew/trip_history_screen.dart';
import 'package:aerocrew/screens/crew/rate_trip_screen.dart';
import 'package:aerocrew/screens/crew/change_plan_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aerocrew/screens/shared/support_screen.dart';
import 'package:aerocrew/screens/crew/referral_screen.dart';
import 'package:aerocrew/screens/crew/wallet_screen.dart';
import 'package:aerocrew/screens/crew/settings_screen.dart';

class CrewProfileViewScreen extends StatefulWidget {
  const CrewProfileViewScreen({super.key});

  @override
  State<CrewProfileViewScreen> createState() => _CrewProfileViewScreenState();
}

class _CrewProfileViewScreenState extends State<CrewProfileViewScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  String get productName {
    switch (userData['product'] ?? 'aeropool') {
      case 'aeroflex': return 'AeroFlex';
      case 'aerosolo': return 'AeroSolo';
      default: return 'AeroPool';
    }
  }

  Color get productColor {
    switch (userData['product'] ?? 'aeropool') {
      case 'aeroflex': return const Color(0xFF378ADD);
      case 'aerosolo': return const Color(0xFFEF9F27);
      default: return AeroColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AeroColors.amber))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProfileCard(),
                    _buildMenuSection(),
                  ],
                ),
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
              Text('MY PROFILE',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Account details',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const Spacer(),
          GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
  ),
  child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AeroColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AeroColors.amber.withValues(alpha: 0.3), width: 0.5),
              ),
              child: const Text('Edit',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AeroColors.amber)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AeroColors.navyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AeroColors.divider, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AeroColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  (userData['name'] ?? 'C').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AeroColors.amber),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(userData['name'] ?? 'Crew Member',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(userData['email'] ?? '',
                style: const TextStyle(fontSize: 13, color: AeroColors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: productColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: productColor.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Text(productName,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: productColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (userData['status'] == 'verified'
                            ? AeroColors.success
                            : AeroColors.amber)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          userData['status'] == 'verified'
                              ? Icons.verified
                              : Icons.pending,
                          size: 11,
                          color: userData['status'] == 'verified'
                              ? AeroColors.success
                              : AeroColors.amber),
                      const SizedBox(width: 4),
                      Text(
                          userData['status'] == 'verified'
                              ? 'Verified'
                              : 'Pending',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: userData['status'] == 'verified'
                                  ? AeroColors.success
                                  : AeroColors.amber)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AeroColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildProfileStat(
                    'Airline', userData['airline'] ?? '—', Icons.flight),
                _buildProfileStat('Base',
                    userData['baseAirport'] ?? '—', Icons.location_on_outlined),
                _buildProfileStat(
                    'Zone', userData['homeZone'] ?? '—', Icons.home_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AeroColors.amber, size: 18),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AeroColors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'icon': Icons.history,
        'label': 'Trip history',
        'desc': 'View all past trips',
        'color': AeroColors.infoText,
        'screen': const TripHistoryScreen(),
      },
      {
        'icon': Icons.star_outline,
        'label': 'Rate a trip',
        'desc': 'Leave feedback for your driver',
        'color': AeroColors.amber,
        'screen': const RateTripScreen(),
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Change plan',
        'desc': 'Switch between AeroPool, Flex, Solo',
        'color': AeroColors.success,
        'screen': const ChangePlanScreen(),
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
        'desc': 'Credits, cashback and rewards',
        'color': const Color(0xFFEF9F27),
        'screen': const WalletScreen(),
      },
      {
        'icon': Icons.card_giftcard_outlined,
        'label': 'Refer & earn',
        'desc': 'Earn RM50 per referral',
        'color': AeroColors.success,
        'screen': const ReferralScreen(),
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Settings',
        'desc': 'Notifications, privacy, preferences',
        'color': AeroColors.grey,
        'screen': const SettingsScreen(),
      },
      {
        'icon': Icons.headset_mic_outlined,
        'label': 'Support',
        'desc': 'Help, FAQ and contact us',
        'color': const Color(0xFF378ADD),
        'screen': const SupportScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...menuItems.map((item) => GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => item['screen'] as Widget)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
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
                          color: (item['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'] as IconData,
                            color: item['color'] as Color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['label'] as String,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            Text(item['desc'] as String,
                                style: const TextStyle(
                                    fontSize: 11, color: AeroColors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 13, color: AeroColors.grey),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _signOut,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AeroColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AeroColors.danger.withValues(alpha: 0.2), width: 0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: AeroColors.danger, size: 16),
                  SizedBox(width: 8),
                  Text('Sign out',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AeroColors.danger)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('AeroCrew v1.0.0',
              style: TextStyle(fontSize: 11, color: AeroColors.lightGrey)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}