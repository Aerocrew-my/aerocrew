import 'package:aerocrew/features/trips/domain/trip.dart';

Map<String, dynamic> legacyTripView(Trip trip) => {
  'id': trip.id,
  'status': trip.status.name,
  'date': tripDate(trip.scheduledPickupAt),
  'pickupTime': tripTime(trip.scheduledPickupAt),
  'arrivalTime': tripTime(trip.requiredArrivalAt),
  'zone': trip.pickupStops.isEmpty ? null : trip.pickupStops.first.address,
  'airport': trip.airport,
  'terminal': trip.terminal,
  'driverName': trip.driverName,
  'vehicle': trip.vehicleDescription,
  'plate': trip.vehiclePlate,
  'crewCount': trip.crewIds.length,
  'pickupStopCount': trip.pickupStops.length,
  'earnings': trip.fare ?? 0,
};

String tripDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String tripTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
