import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.tripId,
  });
  final String id, type, title, body;
  final bool read;
  final DateTime createdAt;
  final String? tripId;
  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['createdAt'];
    final date = switch (raw) {
      Timestamp v => v.toDate(),
      DateTime v => v,
      String v => DateTime.tryParse(v),
      _ => null,
    };
    return AppNotification(
      id: id,
      type: map['type']?.toString() ?? 'info',
      title: map['title']?.toString().trim() ?? '',
      body: map['body']?.toString().trim() ?? '',
      read: map['read'] == true,
      createdAt: date ?? DateTime.fromMillisecondsSinceEpoch(0),
      tripId: map['tripId']?.toString(),
    );
  }
}

int unreadNotificationCount(Iterable<AppNotification> values) =>
    values.where((value) => !value.read).length;
