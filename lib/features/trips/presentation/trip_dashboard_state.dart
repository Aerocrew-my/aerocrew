import 'package:aerocrew/features/trips/domain/trip.dart';

sealed class TripDashboardState {
  const TripDashboardState();
}

class TripDashboardInitial extends TripDashboardState {
  const TripDashboardInitial();
}

class TripDashboardLoading extends TripDashboardState {
  const TripDashboardLoading();
}

class TripDashboardEmpty extends TripDashboardState {
  const TripDashboardEmpty();
}

class TripDashboardFailure extends TripDashboardState {
  const TripDashboardFailure(this.message);
  final String message;
}

class TripDashboardLoaded extends TripDashboardState {
  const TripDashboardLoaded({required this.trips, this.active, this.upcoming});
  final List<Trip> trips;
  final Trip? active, upcoming;
  factory TripDashboardLoaded.fromTrips(List<Trip> trips) {
    final ordered = [...trips]
      ..sort((a, b) => a.scheduledPickupAt.compareTo(b.scheduledPickupAt));
    Trip? active;
    Trip? upcoming;
    for (final trip in ordered) {
      if (active == null && trip.isActive) active = trip;
      if (upcoming == null && trip.isUpcoming) upcoming = trip;
    }
    return TripDashboardLoaded(
      trips: List.unmodifiable(ordered),
      active: active,
      upcoming: upcoming,
    );
  }
}

TripDashboardState dashboardStateFor(List<Trip> trips) => trips.isEmpty
    ? const TripDashboardEmpty()
    : TripDashboardLoaded.fromTrips(trips);
