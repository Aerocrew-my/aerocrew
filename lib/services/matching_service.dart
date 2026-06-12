import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> matchCrewToPool({
    required String flightNumber,
    required DateTime flightDate,
    required String departureTime,
    required String airport,
    required String zone,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final dateStr =
          '${flightDate.year}-${flightDate.month.toString().padLeft(2, '0')}-${flightDate.day.toString().padLeft(2, '0')}';

      // Parse departure time
      final parts = departureTime.split(':');
      final depHour = int.parse(parts[0]);
      final depMin = int.parse(parts[1]);

      // Calculate pickup time (2.5 hours before)
      final pickupMinutes = (depHour * 60 + depMin) - 150;
      final pickupHour = pickupMinutes ~/ 60;
      final pickupMin = pickupMinutes % 60;
      final pickupTime =
          '${pickupHour.toString().padLeft(2, '0')}:${pickupMin.toString().padLeft(2, '0')}';

      // Normalize zone
      final normalizedZone = _normalizeZone(zone);

      // Look for existing pool
      final poolQuery = await _db
          .collection('pools')
          .where('airport', isEqualTo: airport)
          .where('zone', isEqualTo: normalizedZone)
          .where('date', isEqualTo: dateStr)
          .where('status', isEqualTo: 'open')
          .limit(1)
          .get();

      String poolId;
      String matchStatus;

      if (poolQuery.docs.isNotEmpty) {
        // Join existing pool
        poolId = poolQuery.docs.first.id;
        await _db.collection('pools').doc(poolId).update({
          'crewIds': FieldValue.arrayUnion([uid]),
          'count': FieldValue.increment(1),
        });
        matchStatus = 'matched';
      } else {
        // Create new pool
        final newPool = await _db.collection('pools').add({
          'airport': airport,
          'zone': normalizedZone,
          'date': dateStr,
          'departureTime': departureTime,
          'pickupTime': pickupTime,
          'crewIds': [uid],
          'count': 1,
          'maxCapacity': 8,
          'status': 'open',
          'operatorId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        poolId = newPool.id;
        matchStatus = 'pool_created';
      }

      // Save trip to user's roster
      await _db.collection('trips').add({
        'crewId': uid,
        'poolId': poolId,
        'flightNumber': flightNumber,
        'flightDate': dateStr,
        'departureTime': departureTime,
        'pickupTime': pickupTime,
        'airport': airport,
        'zone': normalizedZone,
        'status': matchStatus,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user status
      await _db.collection('users').doc(uid).update({
        'lastMatchedAt': FieldValue.serverTimestamp(),
        'activePoolId': poolId,
      });

      return {
        'status': matchStatus,
        'poolId': poolId,
        'pickupTime': pickupTime,
        'zone': normalizedZone,
      };
    } catch (e) {
      throw Exception('Matching failed: $e');
    }
  }

  static String _normalizeZone(String zone) {
    final lower = zone.toLowerCase();
    if (lower.contains('petaling jaya') || lower.contains('pj')) {
      return 'Petaling Jaya';
    } else if (lower.contains('ara damansara')) {
      return 'Ara Damansara';
    } else if (lower.contains('shah alam')) {
      return 'Shah Alam';
    } else if (lower.contains('subang')) {
      return 'Subang Jaya';
    } else if (lower.contains('cyberjaya')) {
      return 'Cyberjaya';
    } else if (lower.contains('nilai')) {
      return 'Nilai';
    } else if (lower.contains('damansara')) {
      return 'Damansara';
    } else if (lower.contains('putra heights')) {
      return 'Putra Heights';
    }
    return zone;
  }

  static Future<List<Map<String, dynamic>>> getCrewTrips() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _db
          .collection('trips')
          .where('crewId', isEqualTo: uid)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getOperatorJobs() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _db
          .collection('pools')
          .where('operatorId', isEqualTo: uid)
          .where('status', isEqualTo: 'assigned')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }
}