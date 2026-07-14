import 'trip.dart';

class TripTransitions {
  static const Map<TripStatus, Set<TripStatus>> _allowed = {
    TripStatus.draft: {TripStatus.requested, TripStatus.cancelled},
    TripStatus.requested: {
      TripStatus.matching,
      TripStatus.cancelled,
      TripStatus.failed,
    },
    TripStatus.matching: {
      TripStatus.assigned,
      TripStatus.cancelled,
      TripStatus.failed,
    },
    TripStatus.assigned: {
      TripStatus.accepted,
      TripStatus.matching,
      TripStatus.cancelled,
    },
    TripStatus.accepted: {TripStatus.driverEnRoute, TripStatus.cancelled},
    TripStatus.driverEnRoute: {TripStatus.driverArrived, TripStatus.failed},
    TripStatus.driverArrived: {TripStatus.boarding, TripStatus.failed},
    TripStatus.boarding: {TripStatus.inTransit, TripStatus.failed},
    TripStatus.inTransit: {TripStatus.arrived, TripStatus.failed},
    TripStatus.arrived: {TripStatus.completed},
  };
  static bool canTransition(TripStatus from, TripStatus to) =>
      _allowed[from]?.contains(to) ?? false;
  static TripStatus? operatorNext(TripStatus status) => switch (status) {
    TripStatus.assigned => TripStatus.accepted,
    TripStatus.accepted => TripStatus.driverEnRoute,
    TripStatus.driverEnRoute => TripStatus.driverArrived,
    TripStatus.driverArrived => TripStatus.boarding,
    TripStatus.boarding => TripStatus.inTransit,
    TripStatus.inTransit => TripStatus.arrived,
    TripStatus.arrived => TripStatus.completed,
    _ => null,
  };
}
