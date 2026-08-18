import 'package:aerocrew/features/operations/domain/operational_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorVehicleRepository {
  OperatorVehicleRepository(this._db);
  final FirebaseFirestore _db;

  Future<List<Vehicle>> listEligible(
    String operatorId, {
    required int capacity,
  }) async {
    final snapshot = await _db
        .collection('vehicles')
        .where('operatorId', isEqualTo: operatorId)
        .get();
    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          final status = data['status']?.toString().toLowerCase();
          return data['active'] != false &&
              data['verified'] != false &&
              data['approved'] != false &&
              !{'inactive', 'maintenance', 'suspended'}.contains(status) &&
              (data['capacity'] as num?) != null &&
              (data['capacity'] as num).toInt() >= capacity;
        })
        .map((doc) {
          final data = doc.data();
          final makeModel = [
            data['make'],
            data['model'],
          ].whereType<String>().where((value) => value.isNotEmpty).join(' ');
          return Vehicle(
            id: doc.id,
            operatorId: operatorId,
            makeModel: makeModel.isEmpty ? 'Vehicle' : makeModel,
            plate: (data['registration'] ?? data['plate'] ?? '').toString(),
            capacity: (data['capacity'] as num).toInt(),
          );
        })
        .toList(growable: false);
  }
}
