enum ExecutionStopStatus {
  pending,
  arrived,
  onboard,
  noShow,
  skipped,
  cancelled,
}

DateTime? _date(Object? value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is Map) {
    final seconds = value['_seconds'] ?? value['seconds'];
    if (seconds is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        seconds.toInt() * 1000,
        isUtc: true,
      );
    }
  }
  return null;
}

class ExecutionStop {
  const ExecutionStop({
    required this.id,
    required this.sequence,
    required this.status,
    this.scheduledAt,
    this.address,
  });
  final String id;
  final int sequence;
  final ExecutionStopStatus status;
  final DateTime? scheduledAt;
  final String? address;

  bool get isResolved => const {
    ExecutionStopStatus.onboard,
    ExecutionStopStatus.noShow,
    ExecutionStopStatus.skipped,
    ExecutionStopStatus.cancelled,
  }.contains(status);

  factory ExecutionStop.fromMap(Map<String, dynamic> map) => ExecutionStop(
    id: map['id']?.toString() ?? '',
    sequence: (map['sequence'] as num?)?.toInt() ?? 0,
    status: _stopStatus(map['status']),
    scheduledAt: _date(map['scheduledAt']),
    address: (map['address'] ?? map['pickupAddress'] ?? map['pickupZone'])
        ?.toString(),
  );
}

ExecutionStopStatus _stopStatus(Object? value) => switch (value?.toString()) {
  'arrived' => ExecutionStopStatus.arrived,
  'onboard' => ExecutionStopStatus.onboard,
  'no_show' => ExecutionStopStatus.noShow,
  'skipped' => ExecutionStopStatus.skipped,
  'cancelled' => ExecutionStopStatus.cancelled,
  _ => ExecutionStopStatus.pending,
};

class ExecutionTrip {
  const ExecutionTrip({
    required this.id,
    required this.status,
    required this.serviceType,
    required this.stops,
    this.scheduledPickupAt,
    this.requiredArrivalAt,
    this.airport,
    this.terminal,
    this.direction,
    this.driverName,
    this.vehicleDescription,
    this.vehiclePlate,
    this.operatorName,
  });
  final String id, status, serviceType;
  final DateTime? scheduledPickupAt, requiredArrivalAt;
  final String? airport,
      terminal,
      direction,
      driverName,
      vehicleDescription,
      vehiclePlate,
      operatorName;
  final List<ExecutionStop> stops;

  bool get isPool => serviceType == 'aeroPool';
  bool get allStopsResolved =>
      stops.isNotEmpty && stops.every((stop) => stop.isResolved);
  bool get isCompleted => status == 'completed';
  int get resolvedStops => stops.where((stop) => stop.isResolved).length;

  factory ExecutionTrip.fromMap(Map<String, dynamic> map) {
    final rawStops = map['pickupStops'];
    final stops = rawStops is List
        ? (rawStops
              .whereType<Map>()
              .map(
                (value) =>
                    ExecutionStop.fromMap(Map<String, dynamic>.from(value)),
              )
              .toList()
            ..sort((a, b) => a.sequence.compareTo(b.sequence)))
        : <ExecutionStop>[];
    return ExecutionTrip(
      id: map['id']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      serviceType: map['serviceType']?.toString() ?? '',
      stops: stops,
      scheduledPickupAt: _date(map['scheduledPickupAt']),
      requiredArrivalAt: _date(map['requiredArrivalAt']),
      airport: map['airport']?.toString(),
      terminal: map['terminal']?.toString(),
      direction: map['direction']?.toString(),
      driverName: map['driverName']?.toString(),
      vehicleDescription: map['vehicleDescription']?.toString(),
      vehiclePlate: map['vehiclePlate']?.toString(),
      operatorName: map['operatorName']?.toString(),
    );
  }
}

String crewStatusLabel(String status) => switch (status) {
  'accepted' || 'assigned' => 'Operator assigned',
  'driverEnRoute' => 'On the way to pickup',
  'driverArrived' => 'Operator has arrived',
  'boarding' => 'Trip in progress',
  'inTransit' || 'arrived' => 'En route to destination',
  'completed' => 'Completed',
  _ => 'Operator preparing',
};
