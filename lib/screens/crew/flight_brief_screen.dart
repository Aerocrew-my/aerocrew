import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class FlightBriefScreen extends StatelessWidget {
  final Map<String, dynamic> flight;
  const FlightBriefScreen({super.key, required this.flight});

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
                    _buildFlightCard(),
                    const SizedBox(height: 16),
                    _buildTransportCard(),
                    const SizedBox(height: 16),
                    _buildPoolCard(),
                    const SizedBox(height: 16),
                    _buildTimelineCard(),
                    const SizedBox(height: 16),
                    _buildImportantNotes(),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FLIGHT BRIEF',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text(flight['flight'] as String? ?? 'AK6101',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AeroColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('All confirmed',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AeroColors.success)),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AeroColors.navyCard, AeroColors.amber.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AeroColors.amber.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(flight['airport'] as String? ?? 'SZB',
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1)),
                  const Text('Subang Airport',
                      style: TextStyle(
                          fontSize: 11, color: AeroColors.grey)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.flight_takeoff,
                      color: AeroColors.amber, size: 28),
                  Text(flight['departure'] as String? ?? '05:30',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.amber)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('KCH',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1)),
                  const Text('Kuching Airport',
                      style: TextStyle(
                          fontSize: 11, color: AeroColors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AeroColors.divider,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFlightStat('Flight',
                  flight['flight'] as String? ?? 'AK6101'),
              _buildFlightStat('Date',
                  flight['date'] as String? ?? 'Mon 16 Jun'),
              _buildFlightStat('Reporting', '04:30'),
              _buildFlightStat('Duration', '1h 45m'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightStat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AeroColors.grey)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildTransportCard() {
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
          const Text('YOUR TRANSPORT', style: AeroText.label),
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
                      children: List.generate(
                          5,
                          (i) => const Icon(Icons.star,
                              size: 12, color: AeroColors.amber)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _buildTransportDetail(Icons.access_time,
                      'Pickup', flight['pickupTime'] as String? ?? '03:00')),
              Expanded(
                  child: _buildTransportDetail(
                      Icons.location_on_outlined, 'From', 'Your home zone')),
              Expanded(
                  child: _buildTransportDetail(
                      Icons.people, 'Poolmates', '2 crew')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportDetail(
      IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AeroColors.amber),
        const SizedBox(height: 3),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AeroColors.grey)),
      ],
    );
  }

  Widget _buildPoolCard() {
    final poolmates = [
      {'name': 'Siti Nabilah', 'pickup': '03:20', 'zone': 'Ara Damansara'},
      {'name': 'Razif Azman', 'pickup': '03:40', 'zone': 'Subang Jaya'},
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
          const Text('POOLMATES', style: AeroText.label),
          const SizedBox(height: 12),
          ...poolmates.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AeroColors.infoLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          (p['name'] ?? '').substring(0, 1),
                          style: const TextStyle(
                              fontSize: 13,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                          Text(p['zone'] ?? '',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AeroColors.grey)),
                        ],
                      ),
                    ),
                    Text(p['pickup'] ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AeroColors.amber)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final events = [
      {'time': '03:00', 'event': 'Van pickup — your location', 'done': true},
      {'time': '03:20', 'event': 'Pickup Siti — Ara Damansara', 'done': false},
      {'time': '03:40', 'event': 'Pickup Razif — Subang Jaya', 'done': false},
      {'time': '04:15', 'event': 'Arrive SZB Airport', 'done': false},
      {'time': '04:30', 'event': 'Reporting time', 'done': false},
      {'time': '05:30', 'event': 'Departure AK6101', 'done': false},
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
          const Text('FULL TIMELINE', style: AeroText.label),
          const SizedBox(height: 12),
          ...events.asMap().entries.map((e) {
            final isLast = e.key == events.length - 1;
            final event = e.value;
            final isDone = event['done'] as bool;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AeroColors.success
                            : AeroColors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 1,
                        height: 32,
                        margin:
                            const EdgeInsets.symmetric(vertical: 2),
                        color: AeroColors.divider,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: isLast ? 0 : 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(event['event'] as String,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDone
                                      ? AeroColors.greyLight
                                      : Colors.white,
                                  fontWeight: FontWeight.w500)),
                        ),
                        Text(event['time'] as String,
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
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.amber.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AeroColors.amber, size: 16),
              SizedBox(width: 8),
              Text('IMPORTANT NOTES', style: AeroText.label),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Be ready at your pickup point 5 min early',
            'Van cannot wait more than 3 minutes per stop',
            'Contact operator directly if you need to reschedule',
            'Cancellations within 2 hours may incur a fee',
          ].map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle,
                        size: 5, color: AeroColors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(note,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AeroColors.greyLight,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}