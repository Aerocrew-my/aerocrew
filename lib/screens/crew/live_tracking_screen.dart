import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  const LiveTrackingScreen({super.key, required this.trip});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  Timer? _updateTimer;

  int currentStop = 0;
  int etaMinutes = 23;
  String driverStatus = 'En route to first pickup';

  final List<Map<String, dynamic>> stops = [
    {
      'name': 'Faiz Zakaria',
      'address': 'Jalan PJU 1/3, Petaling Jaya',
      'time': '03:00',
      'status': 'next',
    },
    {
      'name': 'Siti Nabilah',
      'address': 'Ara Damansara, PJ',
      'time': '03:20',
      'status': 'upcoming',
    },
    {
      'name': 'Razif Azman',
      'address': 'Subang Jaya SS15',
      'time': '03:40',
      'status': 'upcoming',
    },
    {
      'name': 'Subang Airport (SZB)',
      'address': 'Terminal 1, Subang',
      'time': '04:15',
      'status': 'destination',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && etaMinutes > 0) {
        setState(() => etaMinutes--);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapPlaceholder(),
                    _buildDriverCard(),
                    _buildETACard(),
                    _buildStopsTimeline(),
                    _buildActions(context),
                    const SizedBox(height: 20),
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
              Text('LIVE TRACKING',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Your van is on the way',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AeroColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: AeroColors.success),
                    SizedBox(width: 5),
                    Text('Live',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.success)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 220,
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Stack(
        children: [
          // Fake map grid
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _MapGridPainter(),
            ),
          ),
          // Route line
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _RoutePainter(),
            ),
          ),
          // Van position
          Positioned(
            left: 80,
            top: 80,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40 + (_pulseController.value * 20),
                      height: 40 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AeroColors.amber
                            .withValues(alpha: 0.15 * (1 - _pulseController.value)),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AeroColors.amber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AeroColors.amber.withValues(alpha: 0.4),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: const Icon(Icons.directions_car,
                          color: Colors.white, size: 22),
                    ),
                  ],
                );
              },
            ),
          ),
          // Destination pin
          const Positioned(
            right: 60,
            top: 40,
            child: Icon(Icons.flight_takeoff,
                color: AeroColors.success, size: 28),
          ),
          // Pickup pins
          Positioned(
            left: 140,
            top: 120,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AeroColors.infoText,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 12),
            ),
          ),
          // ETA overlay
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AeroColors.navy.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation,
                      color: AeroColors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text('$etaMinutes min away',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          // Map attribution
          const Positioned(
            bottom: 10,
            right: 10,
            child: Text('Live GPS tracking',
                style: TextStyle(fontSize: 10, color: AeroColors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AeroColors.navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AeroColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AeroColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('AH',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.amber)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ahmad Hassan',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const Text('Toyota Hiace · WXY 1234',
                      style: TextStyle(
                          fontSize: 12, color: AeroColors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(Icons.star,
                              size: 12,
                              color: i < 5
                                  ? AeroColors.amber
                                  : AeroColors.divider)),
                      const SizedBox(width: 4),
                      const Text('4.9 · 342 trips',
                          style: TextStyle(
                              fontSize: 10, color: AeroColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildContactBtn(Icons.phone, AeroColors.success),
                const SizedBox(height: 6),
                _buildContactBtn(
                    Icons.chat_bubble_outline, AeroColors.infoText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBtn(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildETACard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AeroColors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AeroColors.amber.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ETA TO YOUR LOCATION',
                      style: AeroText.label),
                  const SizedBox(height: 4),
                  Text('$etaMinutes minutes',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.amber)),
                  Text(driverStatus,
                      style: const TextStyle(
                          fontSize: 12, color: AeroColors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.access_time,
                  color: AeroColors.amber, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopsTimeline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            const Text('ROUTE & STOPS', style: AeroText.label),
            const SizedBox(height: 12),
            ...stops.asMap().entries.map((entry) {
              final i = entry.key;
              final stop = entry.value;
              final isLast = i == stops.length - 1;
              final status = stop['status'] as String;

              Color dotColor;
              IconData dotIcon;
              switch (status) {
                case 'completed':
                  dotColor = AeroColors.success;
                  dotIcon = Icons.check;
                  break;
                case 'current':
                  dotColor = AeroColors.amber;
                  dotIcon = Icons.directions_car;
                  break;
                case 'next':
                  dotColor = AeroColors.amber;
                  dotIcon = Icons.person;
                  break;
                case 'destination':
                  dotColor = AeroColors.success;
                  dotIcon = Icons.flight_takeoff;
                  break;
                default:
                  dotColor = AeroColors.divider;
                  dotIcon = Icons.person;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: dotColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: dotColor.withValues(alpha: 0.4)),
                        ),
                        child: Icon(dotIcon, size: 14, color: dotColor),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          color: AeroColors.divider,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: isLast ? 0 : 16, top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(stop['name'] as String,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: status == 'upcoming'
                                            ? AeroColors.greyLight
                                            : Colors.white)),
                              ),
                              Text(stop['time'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: dotColor)),
                            ],
                          ),
                          Text(stop['address'] as String,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AeroColors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SosScreen())),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AeroColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AeroColors.danger.withValues(alpha: 0.3),
                      width: 0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos, color: AeroColors.danger, size: 18),
                    SizedBox(width: 6),
                    Text('SOS',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.danger)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_location,
                      color: AeroColors.infoText, size: 18),
                  SizedBox(width: 6),
                  Text('Share location',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A3347).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBA7517).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(100, 100)
      ..cubicTo(140, 80, 180, 130, 220, 100)
      ..cubicTo(260, 70, 290, 90, size.width - 80, 60);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Forward declare SosScreen to avoid import error
class SosScreen extends StatelessWidget {
  const SosScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}