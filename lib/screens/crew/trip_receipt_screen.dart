import 'package:aerocrew/features/receipts/data/api_receipt_repository.dart';
import 'package:aerocrew/features/receipts/data/receipt_repository.dart';
import 'package:aerocrew/features/receipts/domain/trip_receipt.dart';
import 'package:flutter/material.dart';

class TripReceiptScreen extends StatelessWidget {
  TripReceiptScreen({
    super.key,
    String? tripId,
    Map<String, dynamic>? trip,
    this.repository,
  }) : tripId = tripId ?? (trip?['id']?.toString() ?? '');
  final String tripId;
  final ReceiptRepository? repository;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AeroCrew receipt')),
    body: tripId.isEmpty
        ? const Center(child: Text('Receipt is not available for this trip.'))
        : FutureBuilder<TripReceipt>(
            future: (repository ?? ApiReceiptRepository()).getReceipt(tripId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Receipt is not ready or could not be loaded.'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final value = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'AeroCrew',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Divider(),
                          _row('Trip ID', value.tripId),
                          _row('Service', _service(value.serviceType)),
                          _row('Date', _date(value.completedAt)),
                          _row('Pickup', value.pickup ?? 'Not provided'),
                          _row(
                            'Drop-off',
                            value.dropOff?.isNotEmpty == true
                                ? value.dropOff!
                                : 'Not provided',
                          ),
                          _row('Operator', value.operatorName),
                          const Divider(),
                          _row(
                            'Amount',
                            'RM ${(value.bookingValueMinor / 100).toStringAsFixed(2)}',
                          ),
                          _row('Payment', _payment(value.paymentStatus)),
                          _row(
                            'Completion',
                            value.tripStatus == 'completed'
                                ? 'Completed'
                                : value.tripStatus,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
  );
  static Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 105, child: Text(label)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  static String _service(String value) => switch (value) {
    'aeroPool' => 'AeroPool',
    'aeroSolo' => 'AeroSolo',
    _ => 'AeroFlex',
  };
  static String _payment(String value) => switch (value) {
    'paid' => 'Paid',
    'failed' => 'Failed',
    'authorised' || 'processing' => 'Processing',
    'refunded' => 'Refunded',
    _ => 'Pending',
  };
  static String _date(DateTime? value) => value == null
      ? 'Not provided'
      : '${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}';
}
