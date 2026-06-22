import 'package:aerocrew/screens/operator/earnings_screen.dart';
import 'package:aerocrew/screens/operator/availability_screen.dart';
import 'package:aerocrew/screens/operator/operator_profile_view_screen.dart';
import 'package:aerocrew/screens/operator/operator_notifications_screen.dart';
import 'package:aerocrew/screens/operator/route_optimizer_screen.dart';
import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState
    extends State<OperatorDashboardScreen> {
  int currentIndex = 0;
  String operatorName = 'Operator';
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    _loadOperator();
    _loadJobs();
  }

  Future<void> _loadOperator() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          operatorName = doc.data()?['name'] ?? 'Operator';
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get firstName => operatorName.split(' ').first;

  List<Map<String, dynamic>> jobs = [];
  bool jobsLoading = true;

  Future<void> _loadJobs() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('pools')
          .where('operatorId', isEqualTo: uid)
          .limit(10)
          .get();

      if (mounted) {
        if (snapshot.docs.isEmpty) {
          setState(() {
            jobs = _demoJobs();
            jobsLoading = false;
          });
        } else {
          setState(() {
            jobs = snapshot.docs
                .map((doc) => {...doc.data(), 'id': doc.id})
                .toList();
            jobsLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          jobs = _demoJobs();
          jobsLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _demoJobs() => [
  {
    'id': 'job1',
    'date': 'Mon 16 Jun',
    'pickupTime': '03:00',
    'crewCount': 3,
    'zone': 'PJ zone',
    'airport': 'SZB',
    'flightTime': '05:30',
    'earnings': 90.0,
    'status': 'confirmed',
    'crew': [
      {'name': 'Faiz Zakaria', 'zone': 'Petaling Jaya', 'time': '03:00'},
      {'name': 'Siti Nabilah', 'zone': 'Ara Damansara', 'time': '03:20'},
      {'name': 'Razif Azman', 'zone': 'Subang Jaya', 'time': '03:40'},
    ],
  },
  {
    'id': 'job2',
    'date': 'Mon 16 Jun',
    'pickupTime': '07:00',
    'crewCount': 2,
    'zone': 'Shah Alam',
    'airport': 'KLIA',
    'flightTime': '09:30',
    'earnings': 110.0,
    'status': 'confirmed',
    'crew': [
      {'name': 'Ahmad Syafiq', 'zone': 'Shah Alam', 'time': '07:00'},
      {'name': 'Nurul Ain', 'zone': 'Subang', 'time': '07:20'},
    ],
  },
  {
    'id': 'job3',
    'date': 'Tue 17 Jun',
    'pickupTime': '04:30',
    'crewCount': 4,
    'zone': 'Damansara',
    'airport': 'KLIA',
    'flightTime': '07:00',
    'earnings': 160.0,
    'status': 'upcoming',
    'crew': [],
  },
  {
    'id': 'job4',
    'date': 'Wed 18 Jun',
    'pickupTime': '05:00',
    'crewCount': 2,
    'zone': 'Cyberjaya',
    'airport': 'klia2',
    'flightTime': '07:30',
    'earnings': 70.0,
    'status': 'upcoming',
    'crew': [],
  },
];

double get todayEarnings => jobs
    .where((j) => j['date'] == 'Mon 16 Jun')
    .fold(
  0.0,
  (earnings, job) => earnings + ((job['earnings'] ?? 0.0) as double),
);
    
  int get todayJobs => jobs.where((j) => j['date'] == 'Mon 16 Jun').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            _buildNavBar(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: const TextStyle(
                        fontSize: 12, color: AeroColors.grey)),
                const SizedBox(height: 2),
                Text(firstName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => isActive = !isActive),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AeroColors.success.withValues(alpha: 0.12)
                    : AeroColors.navyCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isActive
                        ? AeroColors.success.withValues(alpha: 0.3)
                        : AeroColors.divider,
                    width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AeroColors.success
                          : AeroColors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(isActive ? 'Active' : 'Offline',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AeroColors.success
                              : AeroColors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OperatorNotificationsScreen())),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(Icons.notifications_none,
                  color: AeroColors.grey, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (jobsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AeroColors.amber),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildTodaySection(),
          const SizedBox(height: 20),
          _buildUpcomingSection(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TODAY',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Text('$todayJobs jobs',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AeroColors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AeroColors.amber.withValues(alpha: 0.2),
                  width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EARNINGS',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.amber,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Text('RM${todayEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.amber)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySection() {
    final todayJobsList =
        jobs.where((j) => j['date'] == 'Mon 16 Jun').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TODAY'S JOBS",
            style: TextStyle(
                fontSize: 11,
                color: AeroColors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        ...todayJobsList.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    final upcomingJobsList =
        jobs.where((j) => j['date'] != 'Mon 16 Jun').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('UPCOMING',
            style: TextStyle(
                fontSize: 11,
                color: AeroColors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        ...upcomingJobsList.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final isConfirmed = job['status'] == 'confirmed';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RouteOptimizerScreen(job: job),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AeroColors.navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isConfirmed
                  ? AeroColors.success.withValues(alpha: 0.2)
                  : AeroColors.divider,
              width: 0.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AeroColors.navy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AeroColors.divider, width: 0.5),
                  ),
                  child: Center(
                    child: Text(job['pickupTime'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${job['crewCount']} crew · ${job['zone']} → ${job['airport']}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      Text(
                          '${job['date']} · Flight ${job['flightTime']}',
                          style: const TextStyle(
                              fontSize: 11, color: AeroColors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        'RM${(job['earnings'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.amber)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? AeroColors.success.withValues(alpha: 0.12)
                            : AeroColors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          isConfirmed ? 'Confirmed' : 'Upcoming',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isConfirmed
                                  ? AeroColors.success
                                  : AeroColors.amber)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.calendar_month_outlined, 'label': 'Schedule'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Earnings'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border(
            top: BorderSide(color: AeroColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = currentIndex == i;
          return GestureDetector(
  onTap: () {
    setState(() => currentIndex = i);

    if (i == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AvailabilityScreen(),
        ),
      );
    } else if (i == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EarningsScreen(),
        ),
      );
    } else if (i == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OperatorProfileViewScreen(),
        ),
      );
    }
  }, // <-- missing
  child: Column(
    mainAxisSize: MainAxisSize.min,
        children: [
      Icon(
        items[i]['icon'] as IconData,
        size: 22,
        color: isActive
            ? AeroColors.amber
            : AeroColors.lightGrey,
      ),
      const SizedBox(height: 3),
      Text(
        items[i]['label'] as String,
        style: TextStyle(
          fontSize: 10,
          fontWeight:
              isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive
              ? AeroColors.amber
              : AeroColors.lightGrey,
        ),
      ),
    ],
  ),
);
        }),
      ),
    );
  }
}