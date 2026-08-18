import '../domain/payment.dart';

abstract interface class PaymentRepository {
  Future<CrewPayment> createForTrip(String tripId);
  Future<CrewPayment> getPayment(String paymentId);
  Future<CrewPayment> completeTestPayment(String paymentId);
}
