import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class RosterCalendarScreen extends StatefulWidget {
  const RosterCalendarScreen({super.key});

  @override
  State<RosterCalendarScreen> createState() =>
      _RosterCalendarScreenState();
}

class _RosterCalendarScreenState extends State<RosterCalendarScreen> {
  int selectedDay = 16;
  int currentMonth = 6;
  int currentYear = 2026;

  final Map<int, List<Map<String, dynamic>>> flightsByDay = {
    16: [
      {
        'flight': 'AK6101',
        'time': '05:30',
        'route': 'SZB → KUL',
        'pickup': '03:00',
        'status': 'matched',
        'type': 'outbound'
      },
    ],
    18: [
      {
        'flight': 'AK6204',
        'time': '07:15',
        'route': 'SZB → PEN',
        'pickup': '05:00',
        'status': 'matching',
        'type': 'outbound'
      },
    ],
    20: [
      {
        'flight': 'AK6310',
        'time': '05:45',
        'route': 'SZB → JHB',
        'pickup': '03:30',
        'status': 'scheduled',
        'type': 'outbound'
      },
    ],
    22: [
      {
        'flight': 'AK6415',
        'time': '09:00',
        'route': 'KLIA → SIN',
        'pickup': '06:30',
        'status': 'scheduled',
        'type': 'outbound'
      },
      {
        'flight': 'AK6416',
        'time': '18:30',
        'route': 'SIN → KLIA',
        'pickup': null,
        'status': 'inbound',
        'type': 'inbound'
      },
    ],
    25: [
      {
        'flight': 'AK6520',
        'time': '06:15',
        'route': 'SZB → KBR',
        'pickup': '04:00',
        'status': 'scheduled',
        'type': 'outbound'
      },
    ],
  };

  String get monthName {
    const months = [
      '', 'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August', 'September',
      'October', 'November', 'December'
    ];
    return months[currentMonth];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'matched': return AeroColors.success;
      case 'matching': return AeroColors.amber;
      case 'inbound': return AeroColors.infoText;
      default: return const Color(0xFF378ADD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFlights = flightsByDay[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendar(),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 12),
            Expanded(child: _buildDayDetail(selectedFlights)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ROSTER CALENDAR',
                    style: TextStyle(
                        fontSize: 11,
                        color: AeroColors.amber,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                Text('$monthName $currentYear',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  if (currentMonth == 1) {
                    currentMonth = 12;
                    currentYear--;
                  } else {
                    currentMonth--;
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AeroColors.navyCard,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AeroColors.divider, width: 0.5),
                  ),
                  child: const Icon(Icons.chevron_left,
                      color: AeroColors.grey, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() {
                  if (currentMonth == 12) {
                    currentMonth = 1;
                    currentYear++;
                  } else {
                    currentMonth++;
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AeroColors.navyCard,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AeroColors.divider, width: 0.5),
                  ),
                  child: const Icon(Icons.chevron_right,
                      color: AeroColors.grey, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AeroColors.grey,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 30 + 0, // June starts Monday
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == selectedDay;
              final hasFlights = flightsByDay.containsKey(day);
              final flights = flightsByDay[day] ?? [];
              final hasOutbound =
                  flights.any((f) => f['type'] == 'outbound');
              final hasInbound =
                  flights.any((f) => f['type'] == 'inbound');

              return GestureDetector(
                onTap: () => setState(() => selectedDay = day),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AeroColors.amber
                        : hasFlights
                            ? AeroColors.amber.withOpacity(0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AeroColors.amber
                          : hasFlights
                              ? AeroColors.amber.withOpacity(0.2)
                              : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : hasFlights
                                      ? AeroColors.amber
                                      : AeroColors.grey)),
                      if (hasFlights)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasOutbound)
                              Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : AeroColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasInbound)
                              Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white70
                                      : AeroColors.infoText,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildLegendDot(AeroColors.success, 'Outbound'),
          const SizedBox(width: 16),
          _buildLegendDot(AeroColors.infoText, 'Inbound'),
          const SizedBox(width: 16),
          _buildLegendDot(AeroColors.amber, 'Has flights'),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AeroColors.grey)),
      ],
    );
  }

  Widget _buildDayDetail(List<Map<String, dynamic>> flights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  flights.isEmpty
                      ? 'No flights on day $selectedDay'
                      : '${flights.length} flight${flights.length > 1 ? 's' : ''} on day $selectedDay',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AeroColors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const Spacer(),
              if (flights.isNotEmpty)
                Text('${flights.length} flights',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AeroColors.amber,
                        fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          if (flights.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.event_available,
                      color: AeroColors.grey, size: 28),
                  SizedBox(height: 8),
                  Text('Rest day',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AeroColors.grey)),
                ],
              ),
            )
          else
            ...flights.map((flight) {
              final status = flight['status'] as String;
              final isInbound = flight['type'] == 'inbound';
              final statusColor = _statusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: statusColor.withOpacity(0.3), width: 0.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                              isInbound
                                  ? Icons.flight_land
                                  : Icons.flight_takeoff,
                              color: statusColor,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${flight['flight']} · ${flight['time']}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text(flight['route'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                              isInbound ? 'Inbound' : _statusLabel(status),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor)),
                        ),
                      ],
                    ),
                    if (!isInbound && flight['pickup'] != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AeroColors.navy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_car,
                                color: AeroColors.amber, size: 14),
                            const SizedBox(width: 8),
                            Text(
                                'Pickup at ${flight['pickup']}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AeroColors.greyLight)),
                            const Spacer(),
                            if (status == 'matched')
                              const Text('Van assigned',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.success,
                                      fontWeight: FontWeight.w600))
                            else if (status == 'matching')
                              const Text('Finding van...',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.amber,
                                      fontWeight: FontWeight.w600))
                            else
                              const Text('Awaiting match',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'matched': return 'Van matched';
      case 'matching': return 'Matching...';
      default: return 'Scheduled';
    }
  }
}