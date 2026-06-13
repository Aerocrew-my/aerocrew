import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/operator/operator_trip_history_screen.dart';
import 'package:aerocrew/screens/operator/earnings_screen.dart';
import 'package:aerocrew/screens/operator/availability_screen.dart';
import 'package:aerocrew/screens/shared/help_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorProfileViewScreen extends StatefulWidget {
  const OperatorProfileViewScreen({super.key});

  @override
  State<OperatorProfileViewScreen> createState() =>
      _OperatorProfileViewScreenState();
}

class _OperatorProfileViewScreenState
    extends State<OperatorProfileViewScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AeroColors.amber))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProfileCard(),
                    _buildVehicleCard(),
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
              Text('Operator account',
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
                color: AeroColors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  (userData['name'] ?? 'O').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AeroColors.amber),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(userData['name'] ?? 'Operator',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(userData['email'] ?? '',
                style:
                    const TextStyle(fontSize: 13, color: AeroColors.grey)),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (userData['status'] == 'verified'
                        ? AeroColors.success
                        : AeroColors.amber)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                          ? 'Verified operator'
                          : 'Pending verification',
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
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
            const Text('VEHICLE DETAILS',
                style: TextStyle(
                    fontSize: 11,
                    color: AeroColors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 12),
            _buildVehicleRow(Icons.directions_car_outlined, 'Vehicle',
                userData['vehicleType'] ?? '—'),
            _buildVehicleRow(Icons.confirmation_number_outlined, 'Plate',
                userData['plateNumber'] ?? '—'),
            _buildVehicleRow(Icons.people_outline, 'Capacity',
                '${userData['capacity'] ?? '—'} passengers'),
            _buildVehicleRow(Icons.location_on_outlined, 'Coverage',
                userData['coverageZones'] ?? '—'),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AeroColors.grey),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AeroColors.grey)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final items = [
      {
        'icon': Icons.history,
        'label': 'Trip history',
        'desc': 'View completed jobs',
        'color': AeroColors.infoText,
        'screen': const OperatorTripHistoryScreen(),
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Earnings',
        'desc': 'Income breakdown and payouts',
        'color': AeroColors.amber,
        'screen': const EarningsScreen(),
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Availability',
        'desc': 'Set your schedule',
        'color': AeroColors.success,
        'screen': const AvailabilityScreen(),
      },
      {
        'icon': Icons.help_outline,
        'label': 'Help & support',
        'desc': 'FAQs and contact us',
        'color': AeroColors.grey,
        'screen': const HelpScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...items.map((item) => GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => item['screen'] as Widget)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AeroColors.navyCard,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AeroColors.divider, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.12),
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
                                    fontSize: 11,
                                    color: AeroColors.grey)),
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
                color: AeroColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AeroColors.danger.withOpacity(0.2), width: 0.5),
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