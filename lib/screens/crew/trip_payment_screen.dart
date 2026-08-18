import 'package:aerocrew/features/payments/data/api_payment_repository.dart';
import 'package:aerocrew/features/payments/data/payment_repository.dart';
import 'package:aerocrew/features/payments/domain/payment.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TripPaymentScreen extends StatefulWidget {
  const TripPaymentScreen({super.key, required this.tripId, this.repository});
  final String tripId;
  final PaymentRepository? repository;
  @override
  State<TripPaymentScreen> createState() => _TripPaymentScreenState();
}

class _TripPaymentScreenState extends State<TripPaymentScreen> {
  CrewPayment? _payment;
  String? _error;
  bool _busy = false;
  PaymentRepository get _repo => widget.repository ?? ApiPaymentRepository();
  Future<void> _run(Future<CrewPayment> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final value = await action();
      if (mounted) setState(() => _payment = value);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Payment could not be updated. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = _payment;
    return Scaffold(
      appBar: AppBar(title: const Text('Trip payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (payment?.testMode == true)
              const Align(
                alignment: Alignment.centerLeft,
                child: Chip(label: Text('TEST MODE')),
              ),
            Text(
              'Trip ${widget.tripId}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (payment == null)
              const Text(
                'Create or check payment through AeroCrew’s secure payment service.',
              ),
            if (payment != null)
              Card(
                child: ListTile(
                  title: Text(_label(payment.status)),
                  subtitle: Text(
                    '${payment.currency} ${(payment.amountMinor / 100).toStringAsFixed(2)}',
                  ),
                  leading: Icon(
                    payment.isConfirmedPaid
                        ? Icons.check_circle
                        : Icons.schedule,
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const Spacer(),
            if (payment?.checkoutUrl != null)
              ElevatedButton(
                onPressed: _busy
                    ? null
                    : () async {
                        await launchUrl(
                          payment!.checkoutUrl!,
                          mode: LaunchMode.externalApplication,
                        );
                        if (mounted) {
                          await _run(() => _repo.getPayment(payment.id));
                        }
                      },
                child: const Text('Open secure payment'),
              ),
            if (payment?.testMode == true && !payment!.isConfirmedPaid)
              ElevatedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() => _repo.completeTestPayment(payment.id)),
                child: const Text('Complete test payment'),
              ),
            ElevatedButton(
              onPressed: _busy
                  ? null
                  : payment == null
                  ? () => _run(() => _repo.createForTrip(widget.tripId))
                  : () => _run(() => _repo.getPayment(payment.id)),
              child: Text(
                _busy
                    ? 'Please wait…'
                    : payment == null
                    ? 'Create / check payment'
                    : 'Refresh payment status',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _label(CrewPaymentStatus status) => switch (status) {
    CrewPaymentStatus.paid => 'Payment confirmed',
    CrewPaymentStatus.processing => 'Payment processing',
    CrewPaymentStatus.failed => 'Payment failed',
    CrewPaymentStatus.refunded => 'Payment refunded',
    CrewPaymentStatus.pending => 'Payment pending',
  };
}
