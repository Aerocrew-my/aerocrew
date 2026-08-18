class TripReceipt {
  const TripReceipt({
    required this.id,
    required this.tripId,
    required this.serviceType,
    required this.bookingValueMinor,
    required this.amountCollectedMinor,
    required this.paymentStatus,
    required this.tripStatus,
    required this.operatorName,
    this.completedAt,
    this.pickup,
    this.dropOff,
  });
  final String id, tripId, serviceType, paymentStatus, tripStatus, operatorName;
  final int bookingValueMinor, amountCollectedMinor;
  final DateTime? completedAt;
  final String? pickup, dropOff;
  factory TripReceipt.fromTripResponse(Map<String, dynamic> trip) {
    final raw = trip['receipt'];
    if (raw is! Map) throw const FormatException('Receipt is not ready.');
    final value = Map<String, dynamic>.from(raw);
    final route = value['route'] is Map
        ? Map<String, dynamic>.from(value['route'] as Map)
        : const <String, dynamic>{};
    return TripReceipt(
      id: value['id']?.toString() ?? '',
      tripId: value['tripId']?.toString() ?? trip['id']?.toString() ?? '',
      serviceType:
          value['serviceType']?.toString() ??
          trip['serviceType']?.toString() ??
          '',
      bookingValueMinor: (value['bookingValueMinor'] as num?)?.toInt() ?? 0,
      amountCollectedMinor:
          (value['amountCollectedMinor'] as num?)?.toInt() ?? 0,
      paymentStatus: value['paymentStatus']?.toString() ?? 'pending',
      tripStatus:
          value['tripStatus']?.toString() ?? trip['status']?.toString() ?? '',
      operatorName: trip['operatorName']?.toString().trim().isNotEmpty == true
          ? trip['operatorName'].toString()
          : 'Operator not provided',
      completedAt: _date(value['completedAt']),
      pickup: route['pickupZone']?.toString(),
      dropOff: [
        route['airport'],
        route['terminal'],
      ].where((v) => v != null && v.toString().isNotEmpty).join(' '),
    );
  }
  static DateTime? _date(Object? value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is Map) {
      final seconds = value['_seconds'] ?? value['seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
      }
    }
    return null;
  }
}
