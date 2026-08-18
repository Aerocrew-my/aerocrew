import 'package:aerocrew/features/notifications/data/notification_repository.dart';
import 'package:aerocrew/screens/shared/canonical_notifications_screen.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.repository, this.userId});
  final NotificationRepository? repository;
  final String? userId;
  @override
  Widget build(BuildContext context) => CanonicalNotificationsScreen(
    audience: 'Crew',
    repository: repository,
    userId: userId,
  );
}
