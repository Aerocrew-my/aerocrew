enum CrewPaymentStatus { pending, processing, paid, failed, refunded }

class CrewPayment {
  const CrewPayment({
    required this.id,
    required this.tripId,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.testMode,
    this.checkoutUrl,
  });
  final String id, tripId, currency;
  final int amountMinor;
  final CrewPaymentStatus status;
  final bool testMode;
  final Uri? checkoutUrl;
  bool get isConfirmedPaid => status == CrewPaymentStatus.paid;
  factory CrewPayment.fromMap(Map<String, dynamic> map) {
    final raw = map['status']?.toString();
    final status = switch (raw) {
      'paid' => CrewPaymentStatus.paid,
      'failed' => CrewPaymentStatus.failed,
      'refunded' => CrewPaymentStatus.refunded,
      'processing' || 'authorised' => CrewPaymentStatus.processing,
      _ => CrewPaymentStatus.pending,
    };
    final url = map['checkoutUrl'] ?? map['paymentUrl'] ?? map['purchaseUrl'];
    return CrewPayment(
      id: map['id']?.toString() ?? '',
      tripId: map['tripId']?.toString() ?? '',
      amountMinor: (map['amountMinor'] as num?)?.toInt() ?? 0,
      currency: map['currency']?.toString() ?? 'MYR',
      status: status,
      testMode: map['testMode'] == true,
      checkoutUrl: url == null ? null : Uri.tryParse(url.toString()),
    );
  }
}
