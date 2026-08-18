import '../domain/trip_receipt.dart';

abstract interface class ReceiptRepository {
  Future<TripReceipt> getReceipt(String tripId);
}
