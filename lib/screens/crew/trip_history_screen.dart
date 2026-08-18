import 'package:aerocrew/features/trips/data/firebase_trip_repository.dart';
import 'package:aerocrew/features/trips/data/trip_repository.dart';
import 'package:aerocrew/features/trips/domain/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'trip_receipt_screen.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key, this.repository, this.crewId});
  final TripRepository? repository;
  final String? crewId;
  @override
  Widget build(BuildContext context) {
    final uid = crewId ?? FirebaseAuth.instance.currentUser?.uid;
    final trips =
        repository ?? FirebaseTripRepository(FirebaseFirestore.instance);
    return Scaffold(
      appBar: AppBar(title: const Text('Trip history')),
      body: uid == null
          ? const Center(child: Text('Sign in to view trip history.'))
          : StreamBuilder<List<Trip>>(
              stream: trips.watchCrewTrips(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Trip history could not be loaded.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final completed =
                    snapshot.data!
                        .where((trip) => trip.status == TripStatus.completed)
                        .toList()
                      ..sort(
                        (a, b) =>
                            b.scheduledPickupAt.compareTo(a.scheduledPickupAt),
                      );
                if (completed.isEmpty) {
                  return const Center(child: Text('No completed trips'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: completed.length,
                  itemBuilder: (context, index) {
                    final trip = completed[index];
                    final vehicle = [
                      trip.vehicleDescription,
                      trip.vehiclePlate,
                    ].whereType<String>().join(' · ');
                    return Card(
                      child: ListTile(
                        isThreeLine: true,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(
                          '${_service(trip.serviceType)} · ${trip.airport}${trip.terminal == null ? '' : ' ${trip.terminal}'}',
                        ),
                        subtitle: Text(
                          '${_date(trip.scheduledPickupAt)}\n${trip.operatorName ?? 'Operator not provided'} · ${vehicle.isEmpty ? 'Vehicle not provided' : vehicle}',
                        ),
                        trailing: const Icon(Icons.receipt_long_outlined),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => TripReceiptScreen(tripId: trip.id),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  static String _service(ServiceType value) => switch (value) {
    ServiceType.aeroPool => 'AeroPool',
    ServiceType.aeroFlex => 'AeroFlex',
    ServiceType.aeroSolo => 'AeroSolo',
  };
  static String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
