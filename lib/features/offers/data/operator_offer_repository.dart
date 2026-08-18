import 'package:aerocrew/features/offers/domain/operator_offer.dart';

enum OfferDeclineReason { unavailable, capacity, schedule, other }

abstract interface class OperatorOfferRepository {
  Future<List<OperatorOffer>> listOffers();
  Stream<List<OperatorOffer>> watchOffers();
  Future<void> accept(String offerId, {required String vehicleId});
  Future<void> decline(String offerId, OfferDeclineReason reason);
}

class OperatorOfferException implements Exception {
  const OperatorOfferException(this.message, {this.code, this.statusCode});
  final String message;
  final String? code;
  final int? statusCode;
  @override
  String toString() => message;
}
