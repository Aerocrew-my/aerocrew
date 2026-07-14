import 'dart:typed_data';
import 'package:aerocrew/core/data/firestore_collections.dart';
import 'package:aerocrew/features/roster/data/roster_repository.dart';
import 'package:aerocrew/features/roster/domain/roster.dart';
import 'package:aerocrew/services/anthropic_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRosterRepository implements RosterRepository {
  FirebaseRosterRepository(this._db);
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _rosters =>
      _db.collection(FirestoreCollections.rosters);
  @override
  Stream<List<Roster>> watchCrewRosters(String crewId) => _rosters
      .where('crewId', isEqualTo: crewId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Roster.fromMap(doc.id, doc.data()))
            .toList(),
      );
  @override
  Future<List<RosterDuty>> extract(Uint8List bytes, String mediaType) async =>
      (await AnthropicService.extractRoster(
        bytes,
        mediaType,
      )).map(RosterDuty.fromMap).toList();
  @override
  Future<void> save(Roster roster) =>
      _rosters.doc(roster.id).set(roster.toMap());
}
