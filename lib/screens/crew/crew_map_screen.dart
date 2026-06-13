import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class CrewMapScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  const CrewMapScreen({super.key, required this.trip});

  @override
  State<CrewMapScreen> createState() => _CrewMapScreenState();
}

class _CrewMapScreenState extends State<CrewMapScreen> {
  bool isTracking = true;
  String driverStatus = 'On the way';
  int etaMinutes = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: Stack(
        children: [
          _buildMapPlaceholder(),
          _buildTopBar(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
      ),
      child: Stack(
        children: [
          // Simulated road grid
          CustomPaint(
            painter: _MapGridPainter(),
            child: Container(),
          ),
          // Van marker
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.95, end: 1.05),
                  duration: const Duration(seconds: 1),
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AeroColors.amber,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AeroColors.amber.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.directions_car,
                        color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AeroColors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$etaMinutes min away',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
          // Pickup marker
          Positioned(
            bottom: 220,
            left: 80,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AeroColors.success,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: AeroColors.success.withOpacity(0.4),
                          blurRadius: 12),
                    ],
                  ),
                  child: const Icon(Icons.person_pin,
                      color: Colors.white, size: 18),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AeroColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Your location',
                      style:
                          TextStyle(fontSize: 9, color: Colors.white)),
                ),
              ],
            ),
          ),
          // Airport marker
          Positioned(
            top: 120,
            right: 60,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AeroColors.infoText,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: AeroColors.infoText.withOpacity(0.4),
                          blurRadius: 12),
                    ],
                  ),
                  child: const Icon(Icons.flight,
                      color: Colors.white, size: 18),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AeroColors.infoText,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                      widget.trip['airport'] ?? 'SZB',
                      style: const TextStyle(
                          fontSize: 9, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AeroColors.divider, width: 0.5),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AeroColors.divider, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isTracking
                            ? AeroColors.success
                            : AeroColors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTracking
                          ? '$driverStatus · $etaMinutes min'
                          : 'Tracking paused',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => isTracking = !isTracking),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AeroColors.divider, width: 0.5),
                ),
                child: Icon(
                    isTracking
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: AeroColors.amber,
                    size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AeroColors.navyCard,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AeroColors.divider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AeroColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AeroColors.amberLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car,
                      color: AeroColors.amber, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.trip['van'] ?? 'Ahmad Hassan',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text(
                          '${widget.trip['plate'] ?? 'WXY 1234'} · Toyota Hiace',
                          style: const TextStyle(
                              fontSize: 12, color: AeroColors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AeroColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AeroColors.success.withOpacity(0.3),
                        width: 0.5),
                  ),
                  child: Text('$etaMinutes min',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.success)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildActionBtn(
                        Icons.phone, 'Call', AeroColors.success)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildActionBtn(Icons.chat_bubble_outline,
                        'Chat', AeroColors.infoText)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildActionBtn(
                        Icons.share, 'Share ETA', AeroColors.amber)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AeroColors.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff,
                      color: AeroColors.amber, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        '${widget.trip['flight'] ?? 'AK6101'} departs ${widget.trip['departure'] ?? '05:30'} from ${widget.trip['airport'] ?? 'SZB'}',
                        style: const TextStyle(
                            fontSize: 12, color: AeroColors.greyLight)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2B3C)
      ..strokeWidth = 1.5;

    // Horizontal roads
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical roads
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Highlight main road
    final mainRoad = Paint()
      ..color = const Color(0xFF243447)
      ..strokeWidth = 8;
    canvas.drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.4),
        mainRoad);
    canvas.drawLine(
        Offset(size.width * 0.4, 0),
        Offset(size.width * 0.5, size.height),
        mainRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}