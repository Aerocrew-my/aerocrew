import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/app_notification.dart';
import 'notification_repository.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._db);
  final FirebaseFirestore _db;
  Query<Map<String, dynamic>> _own(String userId) => _db
      .collection('notifications')
      .where('recipientId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(100);
  List<AppNotification> _parse(QuerySnapshot<Map<String, dynamic>> value) =>
      value.docs
          .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
          .toList(growable: false);
  @override
  Future<List<AppNotification>> getNotifications(String userId) async =>
      _parse(await _own(userId).get());
  @override
  Stream<List<AppNotification>> watchNotifications(String userId) =>
      _own(userId).snapshots().map(_parse);
  @override
  Future<void> markRead(String userId, String notificationId) async {
    final ref = _db.collection('notifications').doc(notificationId);
    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data()?['recipientId'] != userId) {
        throw StateError('Notification is not available.');
      }
      if (doc.data()?['read'] != true) {
        transaction.update(ref, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> markAllRead(String userId) async {
    final unread = await _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .limit(100)
        .get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
