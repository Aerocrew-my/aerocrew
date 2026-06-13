import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/roster_upload_screen.dart';

class RosterCalendarScreen extends StatefulWidget {
  const RosterCalendarScreen({super.key});

  @override
  State<RosterCalendarScreen> createState() => _RosterCalendarScreenState();
}

class _RosterCalendarScreenState extends State<RosterCalendarScreen> {
  int selectedDay = 16;
  int currentMonth = 6;
  int currentYear = 2026;

  final Map<int, List<Map<String, dynamic>>> flightsByDay = {
    16: [
      {
        'flight': 'AK6101',
        'dep': '05:30',
        'arr': '08:45',
        'route': 'SZB → KCH',
        'status': 'matched',
        'pickup': '03:00',
      },
    ],
    18: [
      {
        'flight': 'AK6204',
        'dep': '07:15',
        'arr': '10:30',
        'route': 'SZB → PEN',
        'status': 'matching',
        'pickup': '05:00',
      },
    ],
    20: [
      {
        'flight': 'AK6310',
        'dep': '05:45',
        'arr': '09:00',
        'route': 'SZB → BKI',
        'status': 'scheduled',
        'pickup': '03:30',
      },
      {
        'flight': 'AK6311',
        'dep': '14:00',
        'arr': '17:15',
        'route': 'BKI → SZB',
        'status': 'inbound',
        'pickup': null,
      },
    ],
    22: [
      {
        'flight': 'AK6415',
        'dep': '09:00',
        'arr': '12:30',
        'route': 'SZB → LGK',
        'status': 'scheduled',
        'pickup': '06:30',
      },
    ],
    25: [
      {
        'flight': 'AK6501',
        'dep': '06:00',
        'arr': '09:30',
        'route': 'KLIA → SIN',
        'status': 'scheduled',
        'pickup': '03:30',
      },
    ],
    27: [
      {
        'flight': 'AK6604',
        'dep': '08:30',
        'arr': '11:45',
        'route': 'SZB → JHB',
        'status': 'scheduled',
        'pickup': '06:00',
      },
    ],
  };

  String get monthName {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[currentMonth];
  }

  int get daysInMonth {
    return DateTime(currentYear, currentMonth + 1, 0).day;
  }

  int get firstWeekday {
    return DateTime(currentYear, currentMonth, 1).weekday;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'matched': return AeroColors.success;
      case 'matching': return AeroColors.amber;
      case 'inbound': return const Color(0xFF378ADD);
      default: return AeroColors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'matched': return 'Van matched';
      case 'matching': return 'Finding van';
      case 'inbound': return 'Return flight';
      default: return 'Scheduled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFlights = flightsByDay[selectedDay] ?? [];
    final totalFlights = flightsByDay.values.expand((e) => e).length;
    final matchedFlights = flightsByDay.values
        .expand((e) => e)
        .where((f) => f['status'] == 'matched')
        .length;

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
                    _buildStats(totalFlights, matchedFlights),
                    _buildCalendar(),
                    _buildDayDetail(selectedFlights),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RosterUploadScreen())),
        backgroundColor: AeroColors.amber,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Upload roster',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600)),
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
              Text('MY ROSTER',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Flight schedule',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const Spacer(),
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
                child: const Icon(Icons.chevron_left,
                    color: AeroColors.grey, size: 20),
              ),
              Text('$monthName $currentYear',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
              GestureDetector(
                onTap: () => setState(() {
                  if (currentMonth == 12) {
                    currentMonth = 1;
                    currentYear++;
                  } else {
                    currentMonth++;
                  }
                }),
                child: const Icon(Icons.chevron_right,
                    color: AeroColors.grey, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int matched) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard('Flights', '$total', AeroColors.amber),
          const SizedBox(width: 10),
          _buildStatCard('Matched', '$matched', AeroColors.success),
          const SizedBox(width: 10),
          _buildStatCard('Pending', '${total - matched}', const Color(0xFF378ADD)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AeroColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              itemCount: daysInMonth + firstWeekday - 1,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) return const SizedBox();
                final day = index - firstWeekday + 2;
                final hasFlights = flightsByDay.containsKey(day);
                final isSelected = selectedDay == day;
                final flights = flightsByDay[day] ?? [];
                final isMatched = flights.any((f) => f['status'] == 'matched');

                return GestureDetector(
                  onTap: () => setState(() => selectedDay = day),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AeroColors.amber
                          : hasFlights
                              ? AeroColors.amber.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AeroColors.amber
                            : hasFlights
                                ? AeroColors.amber.withOpacity(0.3)
                                : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text('$day',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: hasFlights
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : hasFlights
                                          ? AeroColors.amber
                                          : AeroColors.grey)),
                        ),
                        if (hasFlights && isMatched && !isSelected)
                          Positioned(
                            bottom: 3,
                            right: 3,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AeroColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetail(List<Map<String, dynamic>> flights) {
    return Padding(
      padding: const EdgeInsets.all(20),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const Spacer(),
              if (flights.isNotEmpty)
                Text('$monthName $selectedDay',
                    style: const TextStyle(
                        fontSize: 12, color: AeroColors.grey)),
            ],
          ),
          const SizedBox(height: 12),
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
                          fontWeight: FontWeight.w500,
                          color: AeroColors.grey)),
                ],
              ),
            )
          else
            ...flights.map((flight) {
              final status = flight['status'] as String;
              final color = _statusColor(status);
              final hasPickup = flight['pickup'] != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: color.withOpacity(0.3), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                              status == 'inbound'
                                  ? Icons.flight_land
                                  : Icons.flight_takeoff,
                              color: color,
                              size: 16),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(flight['flight'] as String,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(flight['route'] as String,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AeroColors.grey)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_statusLabel(status),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTimeChip('DEP', flight['dep'] as String,
                            AeroColors.amber),
                        const SizedBox(width: 8),
                        _buildTimeChip('ARR', flight['arr'] as String,
                            AeroColors.grey),
                        if (hasPickup) ...[
                          const SizedBox(width: 8),
                          _buildTimeChip(
                              'PICKUP',
                              flight['pickup'] as String,
                              AeroColors.success),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          Text(time,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}