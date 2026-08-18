enum OperatorOfferStatus { pending, accepted, declined, expired }

enum OfferTargetType { trip, pool }

DateTime? _offerDate(Object? value) => value is String
    ? DateTime.tryParse(value)
    : value is DateTime
    ? value
    : null;

class OperatorOffer {
  const OperatorOffer({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.serviceType,
    required this.airport,
    required this.pickupAt,
    required this.requiredArrivalAt,
    required this.crewCount,
    required this.status,
    required this.expiresAt,
    this.direction,
  });

  final String id, targetId, serviceType, airport;
  final OfferTargetType targetType;
  final String? direction;
  final DateTime pickupAt, requiredArrivalAt, expiresAt;
  final int crewCount;
  final OperatorOfferStatus status;

  bool get isPool => targetType == OfferTargetType.pool;
  bool get isExpired =>
      status == OperatorOfferStatus.expired ||
      (status == OperatorOfferStatus.pending &&
          !expiresAt.isAfter(DateTime.now()));
  bool get isPending => status == OperatorOfferStatus.pending && !isExpired;

  factory OperatorOffer.fromMap(Map<String, dynamic> map) {
    String requiredString(String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw const FormatException();
      }
      return value;
    }

    final pickupAt = _offerDate(map['pickupAt']);
    final requiredArrivalAt = _offerDate(map['requiredArrivalAt']);
    final expiresAt = _offerDate(map['expiresAt']);
    final crewCount = (map['crewCount'] as num?)?.toInt();
    if (pickupAt == null ||
        requiredArrivalAt == null ||
        expiresAt == null ||
        crewCount == null ||
        crewCount < 1) {
      throw const FormatException(
        'Offer contains invalid safe projection data.',
      );
    }
    final targetType = OfferTargetType.values
        .where((value) => value.name == map['targetType'])
        .firstOrNull;
    final status = OperatorOfferStatus.values
        .where((value) => value.name == map['status'])
        .firstOrNull;
    if (targetType == null || status == null) {
      throw const FormatException();
    }
    return OperatorOffer(
      id: requiredString('id'),
      targetType: targetType,
      targetId: requiredString('targetId'),
      serviceType: requiredString('serviceType'),
      airport: requiredString('airport'),
      direction: map['direction'] is String ? map['direction'] as String : null,
      pickupAt: pickupAt,
      requiredArrivalAt: requiredArrivalAt,
      crewCount: crewCount,
      status: status,
      expiresAt: expiresAt,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
