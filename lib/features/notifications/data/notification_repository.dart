import '../domain/app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);
  Stream<List<AppNotification>> watchNotifications(String userId);
  Future<void> markRead(String userId, String notificationId);
  Future<void> markAllRead(String userId);
}
