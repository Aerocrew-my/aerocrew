import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFlutterDashboard extends StatefulWidget {
  const AdminFlutterDashboard({super.key});

  @override
  State<AdminFlutterDashboard> createState() =>
      _AdminFlutterDashboardState();
}

class _AdminFlutterDashboardState extends State<AdminFlutterDashboard> {
  bool isLoading = true;
  int totalCrew = 0;
  int totalOperators = 0;
  int pendingVerifications = 0;
  int activePools = 0;
  List<Map<String, dynamic>> recentUsers = [];
  List<Map<String, dynamic>> pendingUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final allUsers = usersSnap.docs
          .map((d) => {...d.data(), 'id': d.id})
          .toList();

      final poolsSnap = await FirebaseFirestore.instance
          .collection('pools')
          .where('status', isEqualTo: 'open')
          .get();

      if (mounted) {
        setState(() {
          totalCrew =
              allUsers.where((u) => u['role'] == 'crew').length;
          totalOperators =
              allUsers.where((u) => u['role'] == 'operator').length;
          pendingVerifications = allUsers
              .where((u) =>
                  u['status'] == 'pending' ||
                  u['status'] == 'pending_verification')
              .length;
          activePools = poolsSnap.docs.length;
          recentUsers = allUsers.take(5).toList();
          pendingUsers = allUsers
              .where((u) =>
                  u['status'] == 'pending' ||
                  u['status'] == 'pending_verification')
              .take(5)
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateStatus(String uid, String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'status': status});
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AeroColors.amber))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AeroColors.amber,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildStatsGrid(),
                      const SizedBox(height: 20),
                      _buildPendingSection(),
                      const SizedBox(height: 20),
                      _buildRecentUsers(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AeroColors.amber,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.flight, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADMIN PANEL',
                style: TextStyle(
                    fontSize: 11,
                    color: AeroColors.amber,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            Text('AeroCrew overview',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: _loadData,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: const Icon(Icons.refresh,
                color: AeroColors.grey, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildStatTile('Total crew', '$totalCrew',
            Icons.flight_takeoff, AeroColors.amber),
        _buildStatTile('Operators', '$totalOperators',
            Icons.directions_car, const Color(0xFF378ADD)),
        _buildStatTile('Pending review', '$pendingVerifications',
            Icons.pending_actions,
            pendingVerifications > 0
                ? AeroColors.danger
                : AeroColors.success),
        _buildStatTile('Active pools', '$activePools',
            Icons.people, AeroColors.success),
      ],
    );
  }

  Widget _buildStatTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AeroColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    if (pendingUsers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AeroColors.success.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AeroColors.success.withOpacity(0.2), width: 0.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AeroColors.success, size: 18),
            SizedBox(width: 10),
            Text('All verifications complete',
                style: TextStyle(
                    fontSize: 13,
                    color: AeroColors.success,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('PENDING VERIFICATIONS',
                style: AeroText.label),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AeroColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${pendingUsers.length}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AeroColors.danger)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...pendingUsers.map((user) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AeroColors.amber.withOpacity(0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        (user['name'] ?? '?')
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? '—',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text(
                            '${user['role'] == 'crew' ? 'Flight crew' : 'Van operator'} · ${user['status']}',
                            style: const TextStyle(
                                fontSize: 11, color: AeroColors.grey)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _updateStatus(
                            user['id'] as String, 'verified'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AeroColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Approve',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AeroColors.success)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _updateStatus(
                            user['id'] as String, 'rejected'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AeroColors.danger.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Reject',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AeroColors.danger)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRecentUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT SIGNUPS', style: AeroText.label),
        const SizedBox(height: 10),
        ...recentUsers.map((user) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: user['role'] == 'crew'
                          ? const Color(0xFF378ADD).withOpacity(0.12)
                          : AeroColors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                        user['role'] == 'crew'
                            ? Icons.flight_takeoff
                            : Icons.directions_car,
                        size: 16,
                        color: user['role'] == 'crew'
                            ? const Color(0xFF378ADD)
                            : AeroColors.amber),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? '—',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        Text(user['email'] ?? '—',
                            style: const TextStyle(
                                fontSize: 11, color: AeroColors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: user['status'] == 'verified'
                          ? AeroColors.success.withOpacity(0.12)
                          : AeroColors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        user['status'] == 'verified'
                            ? 'Verified'
                            : 'Pending',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: user['status'] == 'verified'
                                ? AeroColors.success
                                : AeroColors.amber)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}