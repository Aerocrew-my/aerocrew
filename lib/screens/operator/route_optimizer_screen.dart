import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/operator/operator_live_job_screen.dart';

class RouteOptimizerScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const RouteOptimizerScreen({super.key, required this.job});

  @override
  State<RouteOptimizerScreen> createState() =>
      _RouteOptimizerScreenState();
}

class _RouteOptimizerScreenState extends State<RouteOptimizerScreen> {
  bool isOptimizing = false;
  bool isOptimized = false;

  List<Map<String, dynamic>> originalOrder = [
    {
      'name': 'Razif Azman',
      'zone': 'Subang Jaya',
      'distance': 8.2,
      'eta': '03:40',
    },
    {
      'name': 'Faiz Zakaria',
      'zone': 'Petaling Jaya',
      'distance': 12.5,
      'eta': '03:00',
    },
    {
      'name': 'Siti Nabilah',
      'zone': 'Ara Damansara',
      'distance': 9.8,
      'eta': '03:20',
    },
  ];

  List<Map<String, dynamic>> optimizedOrder = [
    {
      'name': 'Faiz Zakaria',
      'zone': 'Petaling Jaya',
      'distance': 12.5,
      'eta': '03:00',
    },
    {
      'name': 'Siti Nabilah',
      'zone': 'Ara Damansara',
      'distance': 9.8,
      'eta': '03:18',
    },
    {
      'name': 'Razif Azman',
      'zone': 'Subang Jaya',
      'distance': 8.2,
      'eta': '03:35',
    },
  ];

  Future<void> _optimizeRoute() async {
    setState(() => isOptimizing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isOptimizing = false;
      isOptimized = true;
    });
  }

  List<Map<String, dynamic>> get displayOrder =>
      isOptimized ? optimizedOrder : originalOrder;

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
                    _buildJobCard(),
                    const SizedBox(height: 20),
                    if (!isOptimized) _buildOptimizeCard(),
                    if (isOptimized) _buildSavingsCard(),
                    const SizedBox(height: 20),
                    _buildRouteList(),
                    const SizedBox(height: 20),
                    _buildStartButton(context),
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
              Text('ROUTE OPTIMIZER',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('AI-optimized pickup order',
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

  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flight_takeoff,
                color: AeroColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${widget.job['date'] ?? 'Mon 16 Jun'} · ${widget.job['airport'] ?? 'SZB'}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text(
                    '${displayOrder.length} crew · Flight ${widget.job['flightTime'] ?? '05:30'}',
                    style: const TextStyle(
                        fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Text(
              'RM${(widget.job['earnings'] ?? 90.0).toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AeroColors.amber)),
        ],
      ),
    );
  }

  Widget _buildOptimizeCard() {
    return GestureDetector(
      onTap: isOptimizing ? null : _optimizeRoute,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AeroColors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AeroColors.amber.withValues(alpha: 0.3), width: 1),
        ),
        child: isOptimizing
            ? const Column(
                children: [
                  CircularProgressIndicator(
                      color: AeroColors.amber, strokeWidth: 2),
                  SizedBox(height: 12),
                  Text('AI optimizing your route...',
                      style: TextStyle(
                          fontSize: 13,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600)),
                  Text('Calculating shortest path',
                      style: TextStyle(
                          fontSize: 11, color: AeroColors.grey)),
                ],
              )
            : const Column(
                children: [
                  Icon(Icons.auto_awesome,
                      color: AeroColors.amber, size: 32),
                  SizedBox(height: 10),
                  Text('Optimize pickup route',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text(
                      'AI calculates the most efficient order to pick up all crew',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: AeroColors.grey,
                          height: 1.4)),
                  SizedBox(height: 12),
                  Text('Tap to optimize →',
                      style: TextStyle(
                          fontSize: 12,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  Widget _buildSavingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.success.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: AeroColors.success, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route optimized!',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AeroColors.success)),
                Text('Saves 12 min · 3.2 km shorter',
                    style:
                        TextStyle(fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('−12 min',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AeroColors.success)),
              Text('time saved',
                  style: TextStyle(
                      fontSize: 10, color: AeroColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList() {
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
              Text(
                  isOptimized ? 'OPTIMIZED ORDER' : 'CURRENT ORDER',
                  style: AeroText.label),
              const Spacer(),
              if (isOptimized)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AeroColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('AI optimized',
                      style: TextStyle(
                          fontSize: 10,
                          color: AeroColors.success,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayOrder.asMap().entries.map((entry) {
            final i = entry.key;
            final stop = entry.value;
            final isLast = i == displayOrder.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AeroColors.amber,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        margin:
                            const EdgeInsets.symmetric(vertical: 3),
                        color: AeroColors.divider,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: isLast ? 0 : 8, top: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(stop['name'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              Text(stop['zone'] as String,
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
                            Text(stop['eta'] as String,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AeroColors.amber)),
                            Text(
                                '${(stop['distance'] as double).toStringAsFixed(1)} km',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AeroColors.grey)),
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

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  OperatorLiveJobScreen(job: widget.job)),
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 22),
        label: const Text('Start job',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AeroColors.amber,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}