import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorLiveJobScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const OperatorLiveJobScreen({super.key, required this.job});

  @override
  State<OperatorLiveJobScreen> createState() =>
      _OperatorLiveJobScreenState();
}

class _OperatorLiveJobScreenState extends State<OperatorLiveJobScreen> {
  int currentStop = 0;
  Timer? _timer;
  int elapsedSeconds = 0;

  final List<Map<String, dynamic>> stops = [
    {
      'name': 'Faiz Zakaria',
      'address': 'Jalan PJU 1/3, Petaling Jaya',
      'time': '03:00',
      'phone': '+60123456789',
      'status': 'completed',
    },
    {
      'name': 'Siti Nabilah',
      'address': 'Ara Damansara, PJ',
      'time': '03:20',
      'phone': '+60198765432',
      'status': 'current',
    },
    {
      'name': 'Razif Azman',
      'address': 'Subang Jaya SS15',
      'time': '03:40',
      'phone': '+60112233445',
      'status': 'upcoming',
    },
    {
      'name': 'Subang Airport (SZB)',
      'address': 'Terminal 1, Subang',
      'time': '04:15',
      'phone': null,
      'status': 'destination',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => setState(() => elapsedSeconds++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get elapsedTime {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _markStopComplete() {
    if (currentStop < stops.length - 2) {
      setState(() {
        stops[currentStop]['status'] = 'completed';
        currentStop++;
        stops[currentStop]['status'] = 'current';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedStops =
        stops.where((s) => s['status'] == 'completed').length;

    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildJobBanner(),
            _buildProgressBar(completedStops),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTimerCard(),
                    const SizedBox(height: 16),
                    _buildStopsSection(),
                    const SizedBox(height: 16),
                    _buildActionButtons(context),
                    const SizedBox(height: 16),
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
              Text('LIVE JOB',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Active trip',
                  style: TextStyle(
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
              color: AeroColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AeroColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(elapsedTime,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AeroColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AeroColors.success.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.flight_takeoff,
                color: AeroColors.success, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  '${widget.job['date'] ?? 'Mon 16 Jun'} · Flight ${widget.job['flightTime'] ?? '05:30'} ${widget.job['airport'] ?? 'SZB'}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            Text('RM${(widget.job['earnings'] ?? 90.0).toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AeroColors.amber)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int completed) {
    final total = stops.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$completed of $total stops completed',
                  style: const TextStyle(
                      fontSize: 11, color: AeroColors.grey)),
              Text('${((completed / total) * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completed / total,
              backgroundColor: AeroColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AeroColors.amber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRIP DURATION', style: AeroText.label),
                const SizedBox(height: 4),
                Text(elapsedTime,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Next stop',
                  style: TextStyle(
                      fontSize: 10, color: AeroColors.grey)),
              Text(
                  stops.firstWhere(
                          (s) => s['status'] == 'current',
                          orElse: () =>
                              {'name': 'Airport'})['name'] as String,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AeroColors.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopsSection() {
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
          const Text('STOPS', style: AeroText.label),
          const SizedBox(height: 12),
          ...stops.asMap().entries.map((entry) {
            final i = entry.key;
            final stop = entry.value;
            final status = stop['status'] as String;
            final isLast = i == stops.length - 1;

            Color dotColor;
            switch (status) {
              case 'completed':
                dotColor = AeroColors.success;
                break;
              case 'current':
                dotColor = AeroColors.amber;
                break;
              case 'destination':
                dotColor = AeroColors.infoText;
                break;
              default:
                dotColor = AeroColors.divider;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: dotColor.withValues(alpha: 0.5)),
                      ),
                      child: Icon(
                        status == 'completed'
                            ? Icons.check
                            : status == 'destination'
                                ? Icons.flight_takeoff
                                : Icons.person,
                        size: 12,
                        color: dotColor,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        margin:
                            const EdgeInsets.symmetric(vertical: 3),
                        color: dotColor.withValues(alpha: 0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: isLast ? 0 : 12, top: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(stop['name'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: status == 'upcoming'
                                          ? AeroColors.greyLight
                                          : Colors.white)),
                              Text(stop['address'] as String,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AeroColors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(stop['time'] as String,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: dotColor)),
                            if (status == 'current' &&
                                stop['phone'] != null)
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 3),
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AeroColors.success
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.phone,
                                          size: 10,
                                          color: AeroColors.success),
                                      SizedBox(width: 3),
                                      Text('Call',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  AeroColors.success,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _markStopComplete,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Mark stop as completed',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AeroColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: const Text('Complete job'),
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