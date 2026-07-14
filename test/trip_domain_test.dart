import 'package:aerocrew/features/trips/domain/trip.dart';
import 'package:aerocrew/features/trips/domain/trip_transitions.dart';
import 'package:aerocrew/features/trips/presentation/trip_dashboard_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 7, 14, 8);
  Trip trip({TripStatus status = TripStatus.assigned}) => Trip(
    id: 'trip-1',
    status: status,
    serviceType: ServiceType.aeroPool,
    crewIds: const ['crew-1'],
    operatorId: 'operator-1',
    pickupStops: const [PickupStop(id: 'stop-1', address: 'Subang Jaya')],
    airport: 'KUL',
    terminal: '1',
    scheduledPickupAt: now.add(const Duration(hours: 2)),
    requiredArrivalAt: now.add(const Duration(hours: 4)),
    createdAt: now,
    updatedAt: now,
    createdBy: 'crew-1',
    assignmentStatus: AssignmentStatus.assigned,
  );

  test('Trip serializes and parses without losing canonical fields', () {
    final original = trip();
    final parsed = Trip.fromMap(original.id, original.toMap());
    expect(parsed.status, TripStatus.assigned);
    expect(parsed.crewIds, ['crew-1']);
    expect(parsed.pickupStops.single.address, 'Subang Jaya');
    expect(parsed.scheduledPickupAt, now.add(const Duration(hours: 2)));
    expect(original.toMap()['createdAt'], isA<Timestamp>());
  });

  test('unknown enum values use safe non-privileged fallbacks', () {
    final map = trip().toMap()
      ..addAll({
        'status': 'teleported',
        'assignmentStatus': 'ownerApproved',
        'paymentStatus': 'settledByClient',
        'serviceType': 'limousine',
      });
    final parsed = Trip.fromMap('trip-1', map);
    expect(parsed.status, TripStatus.failed);
    expect(parsed.assignmentStatus, AssignmentStatus.unassigned);
    expect(parsed.paymentStatus, PaymentStatus.pending);
    expect(parsed.serviceType, ServiceType.aeroFlex);
  });

  test('operator action progression is sequential', () {
    expect(
      TripTransitions.operatorNext(TripStatus.assigned),
      TripStatus.accepted,
    );
    expect(
      TripTransitions.canTransition(TripStatus.assigned, TripStatus.completed),
      isFalse,
    );
    expect(
      TripTransitions.operatorNext(TripStatus.arrived),
      TripStatus.completed,
    );
  });

  test('crew and operator access helpers use canonical ownership', () {
    final value = trip();
    expect(value.isCrew('crew-1'), isTrue);
    expect(value.isCrew('crew-2'), isFalse);
    expect(value.isOperator('operator-1'), isTrue);
    expect(value.isOperator('other', operatorProfileId: 'operator-1'), isTrue);
  });

  test('dashboard exposes explicit empty and loaded states', () {
    expect(dashboardStateFor(const []), isA<TripDashboardEmpty>());
    final loaded =
        dashboardStateFor([trip(status: TripStatus.driverEnRoute)])
            as TripDashboardLoaded;
    expect(loaded.active?.id, 'trip-1');
    expect(loaded.trips, hasLength(1));
  });
}
