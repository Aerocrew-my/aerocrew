import 'dart:typed_data';
import 'package:aerocrew/features/roster/domain/roster.dart';

abstract interface class RosterRepository {
  Future<RosterUploadAuthorization> authorizeRosterUpload({
    required String fileName,
    required String mediaType,
  });
  Future<void> uploadRosterBytes(
    RosterUploadAuthorization authorization,
    Uint8List bytes,
  );
  Future<String> createRosterJob({required String uploadId});
  Stream<Roster> watchRoster(String rosterId);
  Future<Roster> getRoster(String rosterId);
  Future<Roster> confirmRoster(String rosterId, List<RosterDuty> duties);
  Future<void> retryRoster(String rosterId);
}

class RosterUploadAuthorization {
  const RosterUploadAuthorization({
    required this.uploadId,
    required this.uploadUrl,
    required this.method,
    required this.headers,
    required this.expiresAt,
  });

  final String uploadId;
  final Uri uploadUrl;
  final String method;
  final Map<String, String> headers;
  final DateTime expiresAt;
}

class RosterRepositoryException implements Exception {
  const RosterRepositoryException(this.message, {this.statusCode, this.code});
  final String message;
  final int? statusCode;
  final String? code;
  @override
  String toString() => message;
}
