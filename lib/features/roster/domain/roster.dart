import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _date(Object? value) => value is Timestamp
    ? value.toDate()
    : value is DateTime
    ? value
    : value is String
    ? DateTime.tryParse(value)
    : null;

enum RosterStatus { uploaded, processing, review, confirmed, failed }

class RosterDuty {
  const RosterDuty({
    required this.id,
    required this.flightNumber,
    required this.airport,
    required this.reportAt,
    this.departureAt,
    this.confirmed = false,
  });
  final String id, flightNumber, airport;
  final DateTime reportAt;
  final DateTime? departureAt;
  final bool confirmed;
  factory RosterDuty.fromMap(Map<String, dynamic> map) {
    final reportAt = _date(map['reportAt']);
    if (reportAt == null)
      throw const FormatException('Roster duty reportAt is invalid.');
    return RosterDuty(
      id: map['id']?.toString() ?? '',
      flightNumber: map['flightNumber']?.toString() ?? '',
      airport: map['airport']?.toString() ?? '',
      reportAt: reportAt,
      departureAt: _date(map['departureAt']),
      confirmed: map['confirmed'] == true,
    );
  }
  Map<String, dynamic> toMap() => {
    'id': id,
    'flightNumber': flightNumber,
    'airport': airport,
    'reportAt': Timestamp.fromDate(reportAt),
    if (departureAt != null) 'departureAt': Timestamp.fromDate(departureAt!),
    'confirmed': confirmed,
  };
}

class Roster {
  const Roster({
    required this.id,
    required this.crewId,
    required this.status,
    required this.duties,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id, crewId;
  final RosterStatus status;
  final List<RosterDuty> duties;
  final DateTime createdAt, updatedAt;
  factory Roster.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = _date(map['createdAt']);
    final updatedAt = _date(map['updatedAt']);
    if (createdAt == null || updatedAt == null)
      throw const FormatException('Roster timestamps are invalid.');
    final status =
        RosterStatus.values
            .where((value) => value.name == map['status'])
            .firstOrNull ??
        RosterStatus.failed;
    return Roster(
      id: id,
      crewId: map['crewId']?.toString() ?? '',
      status: status,
      duties: (map['duties'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => RosterDuty.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  Map<String, dynamic> toMap() => {
    'crewId': crewId,
    'status': status.name,
    'duties': duties.map((duty) => duty.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
