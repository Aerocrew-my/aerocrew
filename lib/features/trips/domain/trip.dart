import 'package:cloud_firestore/cloud_firestore.dart';

enum TripStatus {
  draft,
  requested,
  matching,
  assigned,
  accepted,
  driverEnRoute,
  driverArrived,
  boarding,
  inTransit,
  arrived,
  completed,
  cancelled,
  failed,
}

enum AssignmentStatus {
  unassigned,
  proposed,
  assigned,
  accepted,
  rejected,
  reassignmentRequired,
}

enum PaymentStatus { pending, authorised, paid, failed, refunded }

enum ServiceType { aeroPool, aeroFlex, aeroSolo }

T _enumValue<T extends Enum>(Iterable<T> values, Object? value, T fallback) {
  final raw = value?.toString();
  return values.where((item) => item.name == raw).firstOrNull ?? fallback;
}

DateTime? _date(Object? value) => switch (value) {
  Timestamp value => value.toDate(),
  DateTime value => value,
  String value => DateTime.tryParse(value),
  _ => null,
};

class PickupStop {
  const PickupStop({
    required this.id,
    required this.address,
    this.crewId,
    this.sequence = 0,
    this.scheduledAt,
    this.actualAt,
  });
  final String id;
  final String address;
  final String? crewId;
  final int sequence;
  final DateTime? scheduledAt;
  final DateTime? actualAt;

  factory PickupStop.fromMap(Map<String, dynamic> map) => PickupStop(
    id: map['id']?.toString() ?? '',
    address: map['address']?.toString() ?? '',
    crewId: map['crewId'] as String?,
    sequence: (map['sequence'] as num?)?.toInt() ?? 0,
    scheduledAt: _date(map['scheduledAt']),
    actualAt: _date(map['actualAt']),
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'address': address,
    if (crewId != null) 'crewId': crewId,
    'sequence': sequence,
    if (scheduledAt != null) 'scheduledAt': Timestamp.fromDate(scheduledAt!),
    if (actualAt != null) 'actualAt': Timestamp.fromDate(actualAt!),
  };
}

class Trip {
  const Trip({
    required this.id,
    required this.status,
    required this.serviceType,
    required this.crewIds,
    required this.pickupStops,
    required this.airport,
    required this.scheduledPickupAt,
    required this.requiredArrivalAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.assignmentStatus = AssignmentStatus.unassigned,
    this.paymentStatus = PaymentStatus.pending,
    this.operatorId,
    this.operatorName,
    this.driverId,
    this.driverName,
    this.vehicleId,
    this.vehicleDescription,
    this.vehiclePlate,
    this.terminal,
    this.actualPickupAt,
    this.actualArrivalAt,
    this.fare,
    this.currency = 'MYR',
    this.notes,
  });
  final String id;
  final TripStatus status;
  final ServiceType serviceType;
  final List<String> crewIds;
  final String? operatorId,
      operatorName,
      driverId,
      driverName,
      vehicleId,
      vehicleDescription,
      vehiclePlate;
  final List<PickupStop> pickupStops;
  final String airport;
  final String? terminal;
  final DateTime scheduledPickupAt, requiredArrivalAt, createdAt, updatedAt;
  final DateTime? actualPickupAt, actualArrivalAt;
  final String createdBy;
  final double? fare;
  final String currency;
  final PaymentStatus paymentStatus;
  final AssignmentStatus assignmentStatus;
  final String? notes;

  bool isCrew(String uid) => crewIds.contains(uid);
  bool isOperator(String uid, {String? operatorProfileId}) =>
      operatorId == uid ||
      (operatorProfileId != null && operatorId == operatorProfileId);
  bool get isActive => const {
    TripStatus.accepted,
    TripStatus.driverEnRoute,
    TripStatus.driverArrived,
    TripStatus.boarding,
    TripStatus.inTransit,
    TripStatus.arrived,
  }.contains(status);
  bool get isUpcoming =>
      !isActive &&
      scheduledPickupAt.isAfter(DateTime.now()) &&
      !const {
        TripStatus.completed,
        TripStatus.cancelled,
        TripStatus.failed,
      }.contains(status);

  factory Trip.fromMap(String id, Map<String, dynamic> map) {
    final pickup = _date(map['scheduledPickupAt']);
    final arrival = _date(map['requiredArrivalAt']);
    final created = _date(map['createdAt']);
    final updated = _date(map['updatedAt']);
    if (pickup == null ||
        arrival == null ||
        created == null ||
        updated == null) {
      throw const FormatException(
        'Trip contains missing or invalid timestamps.',
      );
    }
    return Trip(
      id: id,
      status: _enumValue(TripStatus.values, map['status'], TripStatus.failed),
      serviceType: _enumValue(
        ServiceType.values,
        map['serviceType'],
        ServiceType.aeroFlex,
      ),
      crewIds: (map['crewIds'] as List? ?? const []).whereType<String>().toList(
        growable: false,
      ),
      operatorId: map['operatorId'] as String?,
      operatorName: map['operatorName'] as String?,
      driverId: map['driverId'] as String?,
      driverName: map['driverName'] as String?,
      vehicleId: map['vehicleId'] as String?,
      vehicleDescription: map['vehicleDescription'] as String?,
      vehiclePlate: map['vehiclePlate'] as String?,
      pickupStops: (map['pickupStops'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => PickupStop.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      airport: map['airport']?.toString() ?? '',
      terminal: map['terminal'] as String?,
      scheduledPickupAt: pickup,
      requiredArrivalAt: arrival,
      actualPickupAt: _date(map['actualPickupAt']),
      actualArrivalAt: _date(map['actualArrivalAt']),
      createdAt: created,
      updatedAt: updated,
      createdBy: map['createdBy']?.toString() ?? '',
      fare: (map['fare'] as num?)?.toDouble(),
      currency: map['currency']?.toString() ?? 'MYR',
      paymentStatus: _enumValue(
        PaymentStatus.values,
        map['paymentStatus'],
        PaymentStatus.pending,
      ),
      assignmentStatus: _enumValue(
        AssignmentStatus.values,
        map['assignmentStatus'],
        AssignmentStatus.unassigned,
      ),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'serviceType': serviceType.name,
    'crewIds': crewIds,
    'operatorId': operatorId,
    'operatorName': operatorName,
    'driverId': driverId,
    'driverName': driverName,
    'vehicleId': vehicleId,
    'vehicleDescription': vehicleDescription,
    'vehiclePlate': vehiclePlate,
    'pickupStops': pickupStops.map((stop) => stop.toMap()).toList(),
    'airport': airport,
    'terminal': terminal,
    'scheduledPickupAt': Timestamp.fromDate(scheduledPickupAt),
    'requiredArrivalAt': Timestamp.fromDate(requiredArrivalAt),
    'actualPickupAt': actualPickupAt == null
        ? null
        : Timestamp.fromDate(actualPickupAt!),
    'actualArrivalAt': actualArrivalAt == null
        ? null
        : Timestamp.fromDate(actualArrivalAt!),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'createdBy': createdBy,
    'fare': fare,
    'currency': currency,
    'paymentStatus': paymentStatus.name,
    'assignmentStatus': assignmentStatus.name,
    'notes': notes,
  };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
