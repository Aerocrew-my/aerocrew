import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class OperatorNotificationsScreen extends StatefulWidget {
  const OperatorNotificationsScreen({super.key});

  @override
  State<OperatorNotificationsScreen> createState() =>
      _OperatorNotificationsScreenState();
}

class _OperatorNotificationsScreenState
    extends State<OperatorNotificationsScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'job',
      'title': 'New job assigned!',
      'body': '3 crew from PJ zone need pickup on Mon 16 Jun at 03:00 → SZB.',
      'time': '5 min ago',
      'read': false,
      'icon': Icons.work_outline,
      'color': Color(0xFF1D9E75),
    },
    {
      'type': 'payment',
      'title': 'Earnings credited',
      'body': 'RM229.50 has been transferred to your account for June week 1.',
      'time': '2 hours ago',
      'read': false,
      'icon': Icons.payments_outlined,
      'color': Color(0xFFBA7517),
    },
    {
      'type': 'reminder',
      'title': 'Upcoming pickup',
      'body':
          'Reminder: 2 crew pickup tomorrow at 07:00 from Shah Alam → KLIA.',
      'time': '5 hours ago',
      'read': true,
      'icon': Icons.alarm,
      'color': Color(0xFF378ADD),
    },
    {
      'type': 'system',
      'title': 'Account verified',
      'body':
          'Your documents have been approved. You are now active on AeroCrew.',
      'time': 'Yesterday',
      'read': true,
      'icon': Icons.verified_outlined,
      'color': Color(0xFF1D9E75),
    },
    {
      'type': 'rating',
      'title': 'New rating received',
      'body': 'Faiz Zakaria rated your trip 5 stars. Keep it up!',
      'time': '2 days ago',
      'read': true,
      'icon': Icons.star_outline,
      'color': Color(0xFFBA7517),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => n['read'] == false).length;

    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                        border: Border.all(
                          color: AeroColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTIFICATIONS',
                          style: TextStyle(
                            fontSize: 11,
                            color: AeroColors.amber,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          unread > 0 ? '$unread unread' : 'All caught up',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    GestureDetector(
                      onTap: () => setState(() {
                        for (final n in notifications) {
                          n['read'] = true;
                        }
                      }),
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 12,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: notifications.length,
                itemBuilder: (context, i) {
                  final n = notifications[i];
                  final isUnread = n['read'] == false;
                  final color = n['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(() => n['read'] = true),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? color.withValues(alpha: 0.05)
                            : AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUnread
                              ? color.withValues(alpha: 0.2)
                              : AeroColors.divider,
                          width: isUnread ? 1 : 0.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              n['icon'] as IconData,
                              color: color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isUnread
                                              ? Colors.white
                                              : AeroColors.greyLight,
                                        ),
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n['body'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AeroColors.grey,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n['time'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AeroColors.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
