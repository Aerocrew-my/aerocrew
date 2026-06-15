import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/shared/in_app_chat_screen.dart';

class ActiveJobScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const ActiveJobScreen({super.key, required this.job});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  int completedPickups = 0;
  bool jobCompleted = false;

  List<Map<String, dynamic>> get crew =>
      (widget.job['crew'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: jobCompleted
                  ? _buildCompletedView()
                  : _buildActiveView(),
            ),
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
                const Text('ACTIVE JOB',
                    style: TextStyle(
                        fontSize: 11,
                        color: AeroColors.amber,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                Text(
                    '${widget.job['date'] ?? 'Mon 16 Jun'} · ${widget.job['airport'] ?? 'SZB'}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AeroColors.success.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AeroColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text('Live',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AeroColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = crew.isEmpty ? 1 : crew.length;
    final progress = completedPickups / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$completedPickups of ${crew.length} pickups done',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AeroColors.grey,
                      fontWeight: FontWeight.w500)),
              Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AeroColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AeroColors.amber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildNextPickup(),
          const SizedBox(height: 16),
          _buildCrewList(),
          const SizedBox(height: 16),
          _buildJobSummary(),
        ],
      ),
    );
  }

  Widget _buildNextPickup() {
    if (completedPickups >= crew.length) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AeroColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AeroColors.success.withValues(alpha: 0.3), width: 0.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AeroColors.success, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'All crew picked up! Head to the airport.',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final next = crew[completedPickups];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AeroColors.amber.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NEXT PICKUP',
              style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AeroColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person,
                    color: AeroColors.amber, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(next['name'] as String,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(next['zone'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: AeroColors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AeroColors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(next['time'] as String,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(
                      () => completedPickups++),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Mark picked up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AeroColors.amber,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => InAppChatScreen(
                              recipientName: next['name'] as String,
                              recipientInitials:
                                  (next['name'] as String)
                                      .substring(0, 2)
                                      .toUpperCase(),
                              recipientColor: AeroColors.amber,
                            ))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AeroColors.navyCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AeroColors.divider, width: 0.5),
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      color: AeroColors.grey, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrewList() {
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
          const Text('ALL CREW',
              style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ...crew.asMap().entries.map((entry) {
            final i = entry.key;
            final member = entry.value;
            final isDone = i < completedPickups;
            final isCurrent = i == completedPickups;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AeroColors.success
                          : isCurrent
                              ? AeroColors.amber
                              : AeroColors.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(member['name'] as String,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDone
                                ? AeroColors.grey
                                : Colors.white,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null)),
                  ),
                  Text(member['time'] as String,
                      style: TextStyle(
                          fontSize: 11,
                          color: isCurrent
                              ? AeroColors.amber
                              : AeroColors.grey,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildJobSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JOB EARNINGS',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                SizedBox(height: 4),
                Text('After 15% commission',
                    style:
                        TextStyle(fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Text(
              'RM${((widget.job['earnings'] as double? ?? 90.0) * 0.85).toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AeroColors.amber)),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.emoji_events,
                color: AeroColors.success, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Job completed!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text('All crew dropped off successfully.',
              style: TextStyle(fontSize: 14, color: AeroColors.grey)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Crew transported',
                    '${crew.length} crew members'),
                _buildSummaryRow('Trip duration', '1h 20min'),
                _buildSummaryRow('Distance', '~35 km'),
                const Divider(color: AeroColors.divider, height: 20),
                _buildSummaryRow(
                    'Earnings',
                    'RM${((widget.job['earnings'] as double? ?? 90.0) * 0.85).toStringAsFixed(0)}',
                    valueColor: AeroColors.amber),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AeroColors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }
}