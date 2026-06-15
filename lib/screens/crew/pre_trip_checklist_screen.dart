import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/live_tracking_screen.dart';

class PreTripChecklistScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  const PreTripChecklistScreen({super.key, required this.trip});

  @override
  State<PreTripChecklistScreen> createState() =>
      _PreTripChecklistScreenState();
}

class _PreTripChecklistScreenState extends State<PreTripChecklistScreen> {
  final List<Map<String, dynamic>> checklist = [
    {
      'title': 'Uniform ready',
      'desc': 'Full uniform pressed and ready to wear',
      'icon': Icons.checkroom_outlined,
      'checked': false,
      'required': true,
    },
    {
      'title': 'Documents ready',
      'desc': 'Passport, staff ID, licence, permits',
      'icon': Icons.badge_outlined,
      'checked': false,
      'required': true,
    },
    {
      'title': 'Bags packed',
      'desc': 'Luggage prepared and by the door',
      'icon': Icons.luggage_outlined,
      'checked': false,
      'required': false,
    },
    {
      'title': 'Phone charged',
      'desc': 'At least 50% battery recommended',
      'icon': Icons.battery_charging_full_outlined,
      'checked': false,
      'required': false,
    },
    {
      'title': 'Alarm set',
      'desc': 'Backup alarm 30 min before pickup',
      'icon': Icons.alarm_outlined,
      'checked': false,
      'required': false,
    },
    {
      'title': 'Van confirmed',
      'desc': 'Ahmad Hassan — WXY 1234',
      'icon': Icons.directions_car_outlined,
      'checked': false,
      'required': true,
    },
  ];

  int get checkedCount =>
      checklist.where((c) => c['checked'] == true).length;

  bool get requiredComplete => checklist
      .where((c) => c['required'] == true)
      .every((c) => c['checked'] == true);

  double get progress => checkedCount / checklist.length;

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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTripSummary(),
                    const SizedBox(height: 20),
                    _buildProgressCard(),
                    const SizedBox(height: 20),
                    _buildChecklistItems(),
                    const SizedBox(height: 20),
                    _buildReadyButton(context),
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
              Text('PRE-TRIP CHECKLIST',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Before your pickup',
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

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.amber.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AeroColors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flight_takeoff,
                color: AeroColors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${widget.trip['flight'] ?? 'AK6101'} · ${widget.trip['departure'] ?? '05:30'} departure',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text(
                    'Pickup at ${widget.trip['pickupTime'] ?? '03:00'} · ${widget.trip['airport'] ?? 'SZB'}',
                    style: const TextStyle(
                        fontSize: 12, color: AeroColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$checkedCount/${checklist.length} complete',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AeroColors.amber)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AeroColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AeroColors.amber),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItems() {
    return Column(
      children: checklist.asMap().entries.map((entry) {
        final item = entry.value;
        final isChecked = item['checked'] as bool;
        final isRequired = item['required'] as bool;

        return GestureDetector(
          onTap: () =>
              setState(() => item['checked'] = !isChecked),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isChecked
                  ? AeroColors.success.withOpacity(0.06)
                  : AeroColors.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isChecked
                    ? AeroColors.success.withOpacity(0.3)
                    : AeroColors.divider,
                width: isChecked ? 1 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AeroColors.success.withOpacity(0.12)
                        : AeroColors.navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isChecked ? Icons.check_rounded : item['icon'] as IconData,
                    color: isChecked ? AeroColors.success : AeroColors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['title'] as String,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isChecked
                                      ? AeroColors.greyLight
                                      : Colors.white,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null)),
                          if (isRequired && !isChecked) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AeroColors.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Required',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: AeroColors.danger,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      Text(item['desc'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AeroColors.grey)),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AeroColors.success
                        : AeroColors.navy,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked
                          ? AeroColors.success
                          : AeroColors.divider,
                      width: 0.5,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReadyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: requiredComplete
            ? () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        LiveTrackingScreen(trip: widget.trip)))
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AeroColors.success,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AeroColors.navyCard,
          disabledForegroundColor: AeroColors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                requiredComplete
                    ? Icons.check_circle
                    : Icons.lock_outline,
                size: 18),
            const SizedBox(width: 8),
            Text(
                requiredComplete
                    ? 'I\'m ready — track my van'
                    : 'Complete required items first',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}