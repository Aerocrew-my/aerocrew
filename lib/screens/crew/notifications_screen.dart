import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'matched',
      'title': 'Van matched!',
      'body': 'Ahmad Hassan (WXY 1234) assigned for AK6101 on 16 Jun. Pickup at 03:00.',
      'time': '2 min ago',
      'read': false,
      'icon': Icons.check_circle,
      'color': Color(0xFF1D9E75),
    },
    {
      'type': 'reminder',
      'title': 'Trip reminder',
      'body': 'Your pickup for AK6204 is tomorrow at 05:00. Ahmad Hassan will collect you.',
      'time': '1 hour ago',
      'read': false,
      'icon': Icons.alarm,
      'color': Color(0xFFBA7517),
    },
    {
      'type': 'pool',
      'title': 'Pool updated',
      'body': 'Siti Nabilah joined your pool for 16 Jun. You now have 3 poolmates.',
      'time': '3 hours ago',
      'read': true,
      'icon': Icons.people,
      'color': Color(0xFF378ADD),
    },
    {
      'type': 'system',
      'title': 'Profile verified',
      'body': 'Your staff ID has been verified. You can now book transport.',
      'time': 'Yesterday',
      'read': true,
      'icon': Icons.verified,
      'color': Color(0xFF1D9E75),
    },
    {
      'type': 'reminder',
      'title': 'Upload June roster',
      'body': 'Upload your June roster to ensure transport is arranged for all your flights.',
      'time': '2 days ago',
      'read': true,
      'icon': Icons.upload_file,
      'color': Color(0xFFBA7517),
    },
    {
      'type': 'payment',
      'title': 'Subscription renewed',
      'body': 'Your AeroPool subscription has been renewed for June 2026. RM750 charged.',
      'time': '3 days ago',
      'read': true,
      'icon': Icons.receipt,
      'color': Color(0xFF378ADD),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unread =
        notifications.where((n) => n['read'] == false).length;

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
                            color: AeroColors.divider, width: 0.5),
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
                        const Text('NOTIFICATIONS',
                            style: TextStyle(
                                fontSize: 11,
                                color: AeroColors.amber,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1)),
                        Text(
                            unread > 0
                                ? '$unread unread'
                                : 'All caught up',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
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
                      child: const Text('Mark all read',
                          style: TextStyle(
                              fontSize: 12,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w500)),
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
                    onTap: () =>
                        setState(() => n['read'] = true),
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
                            child: Icon(n['icon'] as IconData,
                                color: color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          n['title'] as String,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: isUnread
                                                  ? Colors.white
                                                  : AeroColors
                                                      .greyLight)),
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
                                Text(n['body'] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AeroColors.grey,
                                        height: 1.4)),
                                const SizedBox(height: 6),
                                Text(n['time'] as String,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AeroColors.lightGrey)),
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