import 'package:aerocrew/features/notifications/data/notification_repository.dart';
import 'package:aerocrew/screens/shared/canonical_notifications_screen.dart';
import 'package:flutter/material.dart';

class OperatorNotificationsScreen extends StatelessWidget {
  const OperatorNotificationsScreen({super.key, this.repository, this.userId});
  final NotificationRepository? repository;
  final String? userId;
  @override
  Widget build(BuildContext context) => CanonicalNotificationsScreen(
    audience: 'Operator',
    repository: repository,
    userId: userId,
  );
}
