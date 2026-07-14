import 'package:aerocrew/features/trips/domain/trip.dart';

abstract interface class TripRepository {
  Stream<List<Trip>> watchCrewTrips(String crewId);
  Stream<List<Trip>> watchOperatorTrips(String operatorId);
  Future<void> createRequest(Trip trip);
  Future<void> transitionOperatorTrip({
    required Trip trip,
    required String operatorId,
    required TripStatus next,
  });
}
