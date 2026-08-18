import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _date(Object? value) => switch (value) {
  Timestamp value => value.toDate(),
  DateTime value => value,
  String value => DateTime.tryParse(value),
  _ => null,
};

enum RosterStatus {
  uploaded,
  queued,
  processing,
  needsReview,
  confirmed,
  failed;

  static RosterStatus parse(Object? value) => switch (value) {
    'uploaded' => uploaded,
    'queued' => queued,
    'processing' => processing,
    'review' || 'needs_review' => needsReview,
    'confirmed' => confirmed,
    _ => failed,
  };

  String get wireName => this == needsReview ? 'needs_review' : name;
  bool get isTerminal => this == confirmed || this == failed;
}

class RosterDuty {
  const RosterDuty({
    required this.id,
    this.date,
    this.flightNumber,
    this.origin,
    this.destination,
    this.reportTime,
    this.departureTime,
    this.arrivalTime,
    this.releaseTime,
    this.airport,
    this.dutyType,
    this.confirmed = true,
    this.confidence,
  });

  final String id;
  final DateTime? date, reportTime, departureTime, arrivalTime, releaseTime;
  final String? flightNumber, origin, destination, airport, dutyType;
  final bool confirmed;
  final double? confidence;

  RosterDuty copyWith({
    String? flightNumber,
    String? origin,
    String? destination,
    DateTime? date,
    DateTime? reportTime,
    DateTime? departureTime,
    DateTime? arrivalTime,
    DateTime? releaseTime,
    String? airport,
    String? dutyType,
    bool? confirmed,
  }) => RosterDuty(
    id: id,
    date: date ?? this.date,
    flightNumber: flightNumber ?? this.flightNumber,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    reportTime: reportTime ?? this.reportTime,
    departureTime: departureTime ?? this.departureTime,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    releaseTime: releaseTime ?? this.releaseTime,
    airport: airport ?? this.airport,
    dutyType: dutyType ?? this.dutyType,
    confirmed: confirmed ?? this.confirmed,
    confidence: confidence,
  );

  factory RosterDuty.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Roster duty id is missing.');
    }
    return RosterDuty(
      id: id,
      date: _date(map['date']),
      flightNumber: map['flightNumber']?.toString(),
      origin: map['origin']?.toString(),
      destination: map['destination']?.toString(),
      reportTime: _date(map['reportTime'] ?? map['reportAt']),
      departureTime: _date(map['departureTime'] ?? map['departureAt']),
      arrivalTime: _date(map['arrivalTime'] ?? map['arrivalAt']),
      releaseTime: _date(map['releaseTime'] ?? map['releaseAt']),
      airport: map['airport']?.toString(),
      dutyType: map['dutyType']?.toString(),
      confirmed: map['confirmed'] != false,
      confidence: (map['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap({bool includeParserMetadata = true}) => {
    'id': id,
    if (date != null) 'date': date!.toIso8601String(),
    if (flightNumber != null) 'flightNumber': flightNumber,
    if (origin != null) 'origin': origin,
    if (destination != null) 'destination': destination,
    if (reportTime != null) 'reportTime': reportTime!.toIso8601String(),
    if (departureTime != null)
      'departureTime': departureTime!.toIso8601String(),
    if (arrivalTime != null) 'arrivalTime': arrivalTime!.toIso8601String(),
    if (releaseTime != null) 'releaseTime': releaseTime!.toIso8601String(),
    if (airport != null) 'airport': airport,
    if (dutyType != null) 'dutyType': dutyType,
    'confirmed': confirmed,
    if (includeParserMetadata && confidence != null) 'confidence': confidence,
  };

  Map<String, dynamic> toConfirmationMap() => {
    'id': id,
    if (date != null) 'date': date!.toIso8601String(),
    if (flightNumber != null) 'flightNumber': flightNumber,
    if (origin != null) 'origin': origin,
    if (destination != null) 'destination': destination,
    if (reportTime != null) 'reportTime': reportTime!.toIso8601String(),
    if (departureTime != null)
      'departureTime': departureTime!.toIso8601String(),
    if (arrivalTime != null) 'arrivalTime': arrivalTime!.toIso8601String(),
    if (releaseTime != null) 'releaseTime': releaseTime!.toIso8601String(),
    if (airport != null) 'airport': airport,
    if (dutyType != null) 'dutyType': dutyType,
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
    this.sourceFileName,
    this.errorMessage,
  });

  final String id, crewId;
  final RosterStatus status;
  final List<RosterDuty> duties;
  final DateTime createdAt, updatedAt;
  final String? sourceFileName, errorMessage;

  factory Roster.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = _date(map['createdAt']);
    final updatedAt = _date(map['updatedAt']);
    if (id.isEmpty || createdAt == null || updatedAt == null) {
      throw const FormatException('Roster identity or timestamps are invalid.');
    }
    return Roster(
      id: id,
      crewId: map['crewId']?.toString() ?? '',
      status: RosterStatus.parse(map['status']),
      duties: (map['duties'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => RosterDuty.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sourceFileName: map['sourceFileName']?.toString(),
      errorMessage: map['errorMessage']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'crewId': crewId,
    'status': status.wireName,
    'duties': duties.map((duty) => duty.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    if (sourceFileName != null) 'sourceFileName': sourceFileName,
    if (errorMessage != null) 'errorMessage': errorMessage,
  };
}
