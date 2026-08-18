import 'package:aerocrew/constants.dart';
import 'package:aerocrew/features/notifications/data/firestore_notification_repository.dart';
import 'package:aerocrew/features/notifications/data/notification_repository.dart';
import 'package:aerocrew/features/notifications/domain/app_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CanonicalNotificationsScreen extends StatelessWidget {
  const CanonicalNotificationsScreen({
    super.key,
    required this.audience,
    this.repository,
    this.userId,
  });
  final String audience;
  final NotificationRepository? repository;
  final String? userId;
  @override
  Widget build(BuildContext context) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    final repo =
        repository ??
        FirestoreNotificationRepository(FirebaseFirestore.instance);
    return Scaffold(
      backgroundColor: AeroColors.navy,
      appBar: AppBar(title: Text('$audience notifications')),
      body: uid == null
          ? const Center(child: Text('Sign in to view notifications.'))
          : StreamBuilder<List<AppNotification>>(
              stream: repo.watchNotifications(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Notifications could not be loaded. Try again.',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final values = snapshot.data!;
                if (values.isEmpty) {
                  return const Center(child: Text('No notifications yet.'));
                }
                final unread = unreadNotificationCount(values);
                return Column(
                  children: [
                    if (unread > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => repo.markAllRead(uid),
                          child: Text('Mark all read ($unread)'),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: values.length,
                        itemBuilder: (context, index) {
                          final item = values[index];
                          return Card(
                            color: item.read
                                ? AeroColors.navyCard
                                : AeroColors.amber.withValues(alpha: .12),
                            child: ListTile(
                              leading: Icon(
                                _icon(item.type),
                                color: item.read
                                    ? AeroColors.grey
                                    : AeroColors.amber,
                              ),
                              title: Text(
                                item.title.isEmpty
                                    ? 'AeroCrew update'
                                    : item.title,
                              ),
                              subtitle: Text(
                                '${item.body}\n${_time(item.createdAt)}',
                              ),
                              isThreeLine: true,
                              trailing: item.read
                                  ? null
                                  : const Icon(
                                      Icons.circle,
                                      size: 9,
                                      color: AeroColors.amber,
                                    ),
                              onTap: item.read
                                  ? null
                                  : () => repo.markRead(uid, item.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  static IconData _icon(String type) =>
      type.contains('payment') || type.contains('earning')
      ? Icons.payments_outlined
      : type.contains('offer')
      ? Icons.work_outline
      : type.contains('arriv')
      ? Icons.location_on_outlined
      : Icons.notifications_outlined;
  static String _time(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
