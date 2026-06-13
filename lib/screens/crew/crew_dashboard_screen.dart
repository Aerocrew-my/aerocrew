import 'package:aerocrew/screens/crew/trip_history_screen.dart';
import 'package:aerocrew/screens/crew/notifications_screen.dart';
import 'package:aerocrew/screens/crew/billing_screen.dart';
import 'package:aerocrew/screens/crew/crew_profile_view_screen.dart';
import 'package:aerocrew/screens/crew/roster_calendar_screen.dart';
import 'package:aerocrew/screens/crew/crew_map_screen.dart';
import 'package:aerocrew/screens/crew/poolmates_screen.dart';
import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/roster_upload_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrewDashboardScreen extends StatefulWidget {
  const CrewDashboardScreen({super.key});

  @override
  State<CrewDashboardScreen> createState() => _CrewDashboardScreenState();
}

class _CrewDashboardScreenState extends State<CrewDashboardScreen> {
  int currentIndex = 0;
  String userName = 'Crew';
  String userProduct = 'aeropool';
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTrips();
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
          userName = doc.data()?['name'] ?? 'Crew';
          userProduct = doc.data()?['product'] ?? 'aeropool';
          isVerified = doc.data()?['status'] == 'verified';
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get firstName => userName.split(' ').first;

  Color get productColor {
    switch (userProduct) {
      case 'aeroflex': return const Color(0xFF378ADD);
      case 'aerosolo': return const Color(0xFFEF9F27);
      default: return AeroColors.amber;
    }
  }

  String get productName {
    switch (userProduct) {
      case 'aeroflex': return 'AeroFlex';
      case 'aerosolo': return 'AeroSolo';
      default: return 'AeroPool';
    }
  }

  List<Map<String, dynamic>> upcomingTrips = [];
  bool tripsLoading = true;

  Future<void> _loadTrips() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('crewId', isEqualTo: uid)
          .orderBy('createdAt', descending: false)
          .limit(10)
          .get();

      if (mounted) {
        if (snapshot.docs.isEmpty) {
          setState(() {
            upcomingTrips = _demoTrips();
            tripsLoading = false;
          });
        } else {
          setState(() {
            upcomingTrips = snapshot.docs
                .map((doc) => {...doc.data(), 'id': doc.id})
                .toList();
            tripsLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          upcomingTrips = _demoTrips();
          tripsLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _demoTrips() => [
    {
      'flight': 'AK6101',
      'date': 'Mon 16 Jun',
      'departure': '05:30',
      'airport': 'SZB',
      'pickupTime': '03:00',
      'status': 'matched',
      'poolmates': 2,
      'van': 'Ahmad · Toyota Hiace',
      'plate': 'WXY 1234',
      'rating': '4.9',
    },
    {
      'flight': 'AK6204',
      'date': 'Wed 18 Jun',
      'departure': '07:15',
      'airport': 'SZB',
      'pickupTime': '05:00',
      'status': 'matching',
      'poolmates': 0,
      'van': '',
      'plate': '',
      'rating': '',
    },
    {
      'flight': 'AK6310',
      'date': 'Fri 20 Jun',
      'departure': '05:45',
      'airport': 'SZB',
      'pickupTime': '03:30',
      'status': 'scheduled',
      'poolmates': 0,
      'van': '',
      'plate': '',
      'rating': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
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
                Row(
                  children: [
                    Text(firstName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(width: 8),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AeroColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.verified,
                                size: 11, color: AeroColors.success),
                            SizedBox(width: 3),
                            Text('Verified',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AeroColors.success)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: productColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: productColor.withOpacity(0.3), width: 0.5),
            ),
            child: Text(productName,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: productColor)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const NotificationsScreen(),
    ),
  ),
  child: Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: AeroColors.navyCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: AeroColors.divider,
        width: 0.5,
      ),
    ),
    child: const Icon(
      Icons.notifications_none,
      color: AeroColors.grey,
      size: 18,
    ),
  ),
),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (tripsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AeroColors.amber),
      );
    }
    if (upcomingTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.flight_outlined,
                  color: AeroColors.grey, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('No trips yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 6),
            const Text('Upload your roster to get matched',
                style: TextStyle(fontSize: 13, color: AeroColors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RosterUploadScreen())),
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload roster'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AeroColors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildNextTripCard(),
          const SizedBox(height: 20),
          _buildRosterUploadBanner(),
          const SizedBox(height: 20),
          _buildUpcomingSection(),
        ],
      ),
    );
  }

  Widget _buildNextTripCard() {
    final trip = upcomingTrips.first;
    final isMatched = trip['status'] == 'matched';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('NEXT TRIP',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const Spacer(),
              _buildStatusPill(trip['status'] as String),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip['pickupTime'] as String,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1)),
                    Text('Pickup time',
                        style: const TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                    const SizedBox(height: 8),
                    Text('${trip['date']} · ${trip['flight']}',
                        style: const TextStyle(
                            fontSize: 12, color: AeroColors.greyLight)),
                    Text(
                        '${trip['departure']} departure · ${trip['airport']}',
                        style: const TextStyle(
                            fontSize: 12, color: AeroColors.grey)),
                  ],
                ),
              ),
              if (isMatched)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AeroColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people,
                              size: 12, color: AeroColors.success),
                          const SizedBox(width: 4),
                          Text('${trip['poolmates']} poolmates',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AeroColors.success,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (isMatched) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AeroColors.amberLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_car,
                        color: AeroColors.amber, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip['van'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text(
                            '${trip['plate']} · ${trip['rating']} ★',
                            style: const TextStyle(
                                fontSize: 11, color: AeroColors.grey)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => CrewMapScreen(trip: upcomingTrips.first))),
                        child: _buildIconBtn(Icons.map_outlined, AeroColors.amber),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => PoolmatesScreen(
                                      flightNumber: upcomingTrips.first['flight'] as String,
                                      flightDate: upcomingTrips.first['date'] as String,
                                    ))),
                        child: _buildIconBtn(Icons.people_outline, AeroColors.success),
                      ),
                      const SizedBox(width: 6),
                      _buildIconBtn(Icons.phone, AeroColors.infoText),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: color),
    );
  }

  Widget _buildRosterUploadBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RosterUploadScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AeroColors.amber.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AeroColors.amber.withOpacity(0.25), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AeroColors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AeroColors.amber, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload next month\'s roster',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text('AI scans and schedules instantly',
                      style:
                          TextStyle(fontSize: 11, color: AeroColors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AeroColors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('UPCOMING TRIPS',
                style: TextStyle(
                    fontSize: 11,
                    color: AeroColors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TripHistoryScreen())),
              child: const Text('View all',
                  style: TextStyle(
                      fontSize: 12,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...upcomingTrips.skip(1).map((trip) => _buildTripCard(trip)),
      ],
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AeroColors.navy,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: Center(
              child: Text(trip['pickupTime'] as String,
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
                    '${trip['date']} · ${trip['flight']}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text(
                    '${trip['departure']} departure · ${trip['airport']}',
                    style: const TextStyle(
                        fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          _buildStatusPill(trip['status'] as String),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color;
    Color bgColor;
    String label;
    IconData icon;

    switch (status) {
      case 'matched':
        color = AeroColors.success;
        bgColor = AeroColors.success.withOpacity(0.12);
        label = 'Matched';
        icon = Icons.check_circle_outline;
        break;
      case 'matching':
        color = AeroColors.amber;
        bgColor = AeroColors.amber.withOpacity(0.12);
        label = 'Matching';
        icon = Icons.sync;
        break;
      default:
        color = const Color(0xFF378ADD);
        bgColor = const Color(0xFF378ADD).withOpacity(0.12);
        label = 'Scheduled';
        icon = Icons.calendar_today;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.calendar_month_outlined, 'label': 'Roster'},
      {'icon': Icons.credit_card_outlined, 'label': 'Billing'},
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RosterCalendarScreen()));
              } else if (i == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BillingScreen()));
              } else if (i == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CrewProfileViewScreen()));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i]['icon'] as IconData,
                    size: 22,
                    color: isActive ? AeroColors.amber : AeroColors.lightGrey),
                const SizedBox(height: 3),
                Text(items[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? AeroColors.amber : AeroColors.lightGrey)),
              ],
            ),
          );
        }),
      ),
        );
  }
}