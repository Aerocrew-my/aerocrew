import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/rate_trip_screen.dart';

class TripConfirmedScreen extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripConfirmedScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildConfirmedBanner(),
              const SizedBox(height: 20),
              _buildVanCard(),
              const SizedBox(height: 20),
              _buildPoolmatesSection(),
              const SizedBox(height: 20),
              _buildTripDetails(),
              const SizedBox(height: 24),
              _buildActions(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
            Text('TRIP CONFIRMED',
                style: TextStyle(
                    fontSize: 11,
                    color: AeroColors.amber,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            Text('Your ride is booked',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AeroColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AeroColors.success.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AeroColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check_rounded,
                color: AeroColors.success, size: 30),
          ),
          const SizedBox(height: 12),
          const Text('Trip confirmed!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            '${trip['flight'] ?? 'AK6101'} · ${trip['date'] ?? 'Mon 16 Jun'} · ${trip['departure'] ?? '05:30'} departure',
            style: const TextStyle(fontSize: 12, color: AeroColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR VAN',
              style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
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
                    Text(trip['van'] ?? 'Ahmad Hassan',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(
                        '${trip['plate'] ?? 'WXY 1234'} · ${trip['rating'] ?? '4.9'} ★',
                        style: const TextStyle(
                            fontSize: 12, color: AeroColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildContactBtn(
                    Icons.phone, 'Call', AeroColors.success),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildContactBtn(Icons.chat_bubble_outline,
                    'WhatsApp', AeroColors.infoText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactBtn(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildPoolmatesSection() {
    final poolmates = [
      {'name': 'Siti Nabilah', 'zone': 'Ara Damansara', 'time': '03:20'},
      {'name': 'Razif Azman', 'zone': 'Subang Jaya', 'time': '03:40'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('POOLMATES',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AeroColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${poolmates.length} crew',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AeroColors.success,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...poolmates.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AeroColors.infoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (p['name'] ?? 'X').substring(0, 1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AeroColors.infoText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                          Text(p['zone'] ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: AeroColors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AeroColors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(p['time'] ?? '',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRIP DETAILS',
              style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time_outlined, 'Pickup time',
              trip['pickupTime'] ?? '03:00'),
          _buildDetailRow(Icons.location_on_outlined, 'Pickup zone',
              trip['zone'] ?? 'Petaling Jaya'),
          _buildDetailRow(Icons.flight_takeoff, 'Airport',
              trip['airport'] ?? 'SZB'),
          _buildDetailRow(Icons.flight, 'Flight',
              '${trip['flight'] ?? 'AK6101'} · ${trip['departure'] ?? '05:30'}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AeroColors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Back to dashboard',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RateTripScreen())),
            icon: const Icon(Icons.star_outline, size: 16),
            label: const Text('Rate this trip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AeroColors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AeroColors.amber, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}