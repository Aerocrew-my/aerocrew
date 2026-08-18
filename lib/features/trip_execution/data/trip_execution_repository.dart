import '../domain/execution_trip.dart';

enum StopExceptionReason {
  crewNoShow,
  crewCancelled,
  unsafePickup,
  unableToAccess,
  operatorIssue,
  other,
}

abstract interface class TripExecutionRepository {
  Future<List<ExecutionTrip>> getActiveAssignments();
  Future<ExecutionTrip> getTrip(String tripId);
  Future<void> startPickup(String tripId);
  Future<void> arrivePickup(String tripId);
  Future<void> markCrewOnboard(String tripId);
  Future<void> markStopArrived(String tripId, String stopId);
  Future<void> markStopOnboard(String tripId, String stopId);
  Future<void> markStopException(
    String tripId,
    String stopId,
    StopExceptionReason reason, {
    String? detail,
  });
  Future<void> startAirportLeg(String tripId);
  Future<void> completeTrip(String tripId);
}

class TripExecutionException implements Exception {
  const TripExecutionException(
    this.message, {
    this.statusCode,
    this.code,
    this.refreshRequired = false,
  });
  final String message;
  final int? statusCode;
  final String? code;
  final bool refreshRequired;
  @override
  String toString() => message;
}
