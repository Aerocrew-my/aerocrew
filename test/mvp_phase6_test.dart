import 'package:aerocrew/features/earnings/domain/operator_earning.dart';
import 'package:aerocrew/features/notifications/data/notification_repository.dart';
import 'package:aerocrew/features/notifications/domain/app_notification.dart';
import 'package:aerocrew/features/payments/data/payment_repository.dart';
import 'package:aerocrew/features/payments/domain/payment.dart';
import 'package:aerocrew/features/receipts/data/receipt_repository.dart';
import 'package:aerocrew/features/receipts/domain/trip_receipt.dart';
import 'package:aerocrew/screens/crew/notifications_screen.dart';
import 'package:aerocrew/screens/crew/trip_payment_screen.dart';
import 'package:aerocrew/screens/crew/trip_receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payment parsing never promotes an unknown status to paid', () {
    expect(CrewPayment.fromMap({'status': 'paid'}).isConfirmedPaid, isTrue);
    expect(
      CrewPayment.fromMap({'status': 'success'}).status,
      CrewPaymentStatus.pending,
    );
    expect(
      CrewPayment.fromMap({'status': 'authorised'}).status,
      CrewPaymentStatus.processing,
    );
  });
  test('operator earning parses payable and settlement state', () {
    final value = OperatorEarning.fromMap({
      'tripId': 'T1',
      'bookingValueMinor': 10000,
      'operatorPayableMinor': 8500,
      'settlementStatus': 'ready',
    });
    expect(value.operatorPayableMinor, 8500);
    expect(value.settlementStatus, 'ready');
  });
  test('receipt projection excludes internal finance fields', () {
    final value = TripReceipt.fromTripResponse({
      'id': 'T1',
      'operatorName': 'Safe Operator',
      'receipt': {
        'id': 'F1',
        'tripId': 'T1',
        'serviceType': 'aeroPool',
        'bookingValueMinor': 10000,
        'amountCollectedMinor': 10000,
        'paymentStatus': 'paid',
        'tripStatus': 'completed',
        'operatorPayableMinor': 8500,
        'route': {'pickupZone': 'PJ', 'airport': 'SZB'},
      },
    });
    expect(value.tripId, 'T1');
    expect(value.operatorName, 'Safe Operator');
    expect(value.pickup, 'PJ');
  });
  test('unread count reflects canonical records', () {
    final now = DateTime(2026);
    expect(
      unreadNotificationCount([
        AppNotification(
          id: '1',
          type: 'info',
          title: 'A',
          body: 'B',
          read: false,
          createdAt: now,
        ),
        AppNotification(
          id: '2',
          type: 'info',
          title: 'A',
          body: 'B',
          read: true,
          createdAt: now,
        ),
      ]),
      1,
    );
  });
  testWidgets(
    'test payment is visibly labelled and only backend command confirms it',
    (tester) async {
      final repo = _PaymentFake();
      await tester.pumpWidget(
        MaterialApp(
          home: TripPaymentScreen(tripId: 'T1', repository: repo),
        ),
      );
      await tester.tap(find.text('Create / check payment'));
      await tester.pump();
      expect(find.text('TEST MODE'), findsOneWidget);
      expect(find.text('Payment pending'), findsOneWidget);
      expect(repo.completed, isFalse);
      await tester.tap(find.text('Complete test payment'));
      await tester.pump();
      expect(repo.completed, isTrue);
      expect(find.text('Payment confirmed'), findsOneWidget);
    },
  );
  testWidgets('real receipt projection renders canonical values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TripReceiptScreen(tripId: 'T1', repository: _ReceiptFake()),
      ),
    );
    await tester.pump();
    expect(find.text('Safe Operator'), findsOneWidget);
    expect(find.text('RM 100.00'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
  });
  testWidgets(
    'notification empty state is truthful and mark read is delegated',
    (tester) async {
      final repo = _NotificationFake();
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(repository: repo, userId: 'crew'),
        ),
      );
      await tester.pump();
      expect(find.text('Canonical assignment'), findsOneWidget);
      await tester.tap(find.text('Canonical assignment'));
      await tester.pump();
      expect(repo.marked, 'n1');
    },
  );
}

class _PaymentFake implements PaymentRepository {
  bool completed = false;
  CrewPayment get value => CrewPayment(
    id: 'trip_T1',
    tripId: 'T1',
    amountMinor: 10000,
    currency: 'MYR',
    status: completed ? CrewPaymentStatus.paid : CrewPaymentStatus.pending,
    testMode: true,
  );
  @override
  Future<CrewPayment> createForTrip(String tripId) async => value;
  @override
  Future<CrewPayment> getPayment(String paymentId) async => value;
  @override
  Future<CrewPayment> completeTestPayment(String paymentId) async {
    completed = true;
    return value;
  }
}

class _ReceiptFake implements ReceiptRepository {
  @override
  Future<TripReceipt> getReceipt(String tripId) async => const TripReceipt(
    id: 'F1',
    tripId: 'T1',
    serviceType: 'aeroPool',
    bookingValueMinor: 10000,
    amountCollectedMinor: 10000,
    paymentStatus: 'paid',
    tripStatus: 'completed',
    operatorName: 'Safe Operator',
    pickup: 'PJ',
    dropOff: 'SZB',
  );
}

class _NotificationFake implements NotificationRepository {
  String? marked;
  final item = AppNotification(
    id: 'n1',
    type: 'assignment',
    title: 'Canonical assignment',
    body: 'Assigned',
    read: false,
    createdAt: DateTime(2026),
  );
  @override
  Future<List<AppNotification>> getNotifications(String userId) async => [item];
  @override
  Stream<List<AppNotification>> watchNotifications(String userId) =>
      Stream.value([item]);
  @override
  Future<void> markRead(String userId, String notificationId) async {
    marked = notificationId;
  }

  @override
  Future<void> markAllRead(String userId) async {}
}
