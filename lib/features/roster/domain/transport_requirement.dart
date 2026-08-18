import 'package:aerocrew/features/roster/domain/roster.dart';

enum TransportDirection { toAirport, fromAirport }

class TransportRequirementIdentity {
  static TransportDirection? directionFor(RosterDuty duty, String baseAirport) {
    final base = baseAirport.trim().toUpperCase();
    if (base.isEmpty) return null;
    if (duty.origin?.trim().toUpperCase() == base && duty.reportTime != null) {
      return TransportDirection.toAirport;
    }
    if (duty.destination?.trim().toUpperCase() == base &&
        duty.releaseTime != null) {
      return TransportDirection.fromAirport;
    }
    return null;
  }

  static String deterministicId({
    required String crewId,
    required String rosterId,
    required RosterDuty duty,
    required TransportDirection direction,
  }) {
    final instant = direction == TransportDirection.toAirport
        ? duty.reportTime
        : duty.releaseTime;
    final canonical = [
      crewId.trim(),
      rosterId.trim(),
      duty.id.trim(),
      duty.date?.toUtc().toIso8601String() ?? '',
      duty.flightNumber?.trim().toUpperCase() ?? '',
      direction.name,
      duty.airport?.trim().toUpperCase() ?? '',
      instant?.toUtc().toIso8601String() ?? '',
    ].join('|');
    var hash = 0xcbf29ce484222325;
    for (final byte in canonical.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return 'tr_${hash.toRadixString(16).padLeft(16, '0')}';
  }
}
