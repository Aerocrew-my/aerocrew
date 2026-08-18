import 'dart:typed_data';
import 'package:aerocrew/features/roster/domain/roster.dart';

abstract interface class RosterRepository {
  Future<String> createRosterJob({
    required Uint8List bytes,
    required String mediaType,
    required String fileName,
  });
  Stream<Roster> watchRoster(String rosterId);
  Future<Roster> getRoster(String rosterId);
  Future<Roster> confirmRoster(String rosterId, List<RosterDuty> duties);
  Future<void> retryRoster(String rosterId);
}

class RosterRepositoryException implements Exception {
  const RosterRepositoryException(this.message, {this.statusCode, this.code});
  final String message;
  final int? statusCode;
  final String? code;
  @override
  String toString() => message;
}
