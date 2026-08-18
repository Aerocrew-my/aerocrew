class OperatorEarning {
  const OperatorEarning({
    required this.id,
    required this.tripId,
    required this.bookingValueMinor,
    required this.operatorPayableMinor,
    required this.settlementStatus,
    this.completedAt,
  });
  final String id, tripId, settlementStatus;
  final int bookingValueMinor, operatorPayableMinor;
  final DateTime? completedAt;
  factory OperatorEarning.fromMap(Map<String, dynamic> map) => OperatorEarning(
    id: map['id']?.toString() ?? '',
    tripId: map['tripId']?.toString() ?? '',
    bookingValueMinor: (map['bookingValueMinor'] as num?)?.toInt() ?? 0,
    operatorPayableMinor: (map['operatorPayableMinor'] as num?)?.toInt() ?? 0,
    settlementStatus:
        const {'pending', 'ready', 'settled'}.contains(map['settlementStatus'])
        ? map['settlementStatus'].toString()
        : 'pending',
    completedAt: DateTime.tryParse(map['completedAt']?.toString() ?? ''),
  );
}
