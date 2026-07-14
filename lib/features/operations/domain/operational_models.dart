enum NotificationType { trip, roster, payment, system }

class Vehicle {
  const Vehicle({
    required this.id,
    required this.operatorId,
    required this.makeModel,
    required this.plate,
    this.capacity,
  });
  final String id, operatorId, makeModel, plate;
  final int? capacity;
}

class OperatorProfile {
  const OperatorProfile({required this.id, required this.name, this.phone});
  final String id, name;
  final String? phone;
}

class TransportRequirement {
  const TransportRequirement({
    required this.id,
    required this.crewId,
    required this.rosterDutyId,
    required this.status,
  });
  final String id, crewId, rosterDutyId, status;
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.amount,
    required this.currency,
    required this.status,
  });
  final String id, userId, tripId, currency, status;
  final double amount;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
  });
  final String id, userId, title, body;
  final NotificationType type;
  final bool read;
}
