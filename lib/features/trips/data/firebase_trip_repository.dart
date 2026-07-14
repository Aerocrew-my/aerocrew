import 'package:aerocrew/core/data/firestore_collections.dart';
import 'package:aerocrew/features/trips/data/trip_repository.dart';
import 'package:aerocrew/features/trips/domain/trip.dart';
import 'package:aerocrew/features/trips/domain/trip_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTripRepository implements TripRepository {
  FirebaseTripRepository(this._db);
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection(FirestoreCollections.trips);

  @override
  Stream<List<Trip>> watchCrewTrips(String crewId) => _trips
      .where('crewIds', arrayContains: crewId)
      .orderBy('scheduledPickupAt')
      .snapshots()
      .map(_parse);
  @override
  Stream<List<Trip>> watchOperatorTrips(String operatorId) => _trips
      .where('operatorId', isEqualTo: operatorId)
      .orderBy('scheduledPickupAt')
      .snapshots()
      .map(_parse);
  List<Trip> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot
      .docs
      .map((doc) => Trip.fromMap(doc.id, doc.data()))
      .toList(growable: false);
  @override
  Future<void> createRequest(Trip trip) =>
      _trips.doc(trip.id).set(trip.toMap());
  @override
  Future<void> transitionOperatorTrip({
    required Trip trip,
    required String operatorId,
    required TripStatus next,
  }) async {
    if (!trip.isOperator(operatorId) ||
        !TripTransitions.canTransition(trip.status, next) ||
        TripTransitions.operatorNext(trip.status) != next) {
      throw StateError('Unauthorised trip transition.');
    }
    await _trips.doc(trip.id).update({
      'status': next.name,
      'updatedAt': FieldValue.serverTimestamp(),
      if (next == TripStatus.accepted)
        'assignmentStatus': AssignmentStatus.accepted.name,
    });
  }
}
