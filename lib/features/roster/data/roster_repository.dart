import 'dart:typed_data';
import 'package:aerocrew/features/roster/domain/roster.dart';

abstract interface class RosterRepository {
  Stream<List<Roster>> watchCrewRosters(String crewId);
  Future<List<RosterDuty>> extract(Uint8List bytes, String mediaType);
  Future<void> save(Roster roster);
}
