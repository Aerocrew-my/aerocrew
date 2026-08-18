import 'package:aerocrew/constants.dart';
import 'package:aerocrew/services/chip_service.dart';
import 'package:flutter/material.dart';

/// Verifies the server-owned purchase after the checkout redirect.
/// A browser redirect alone is not proof of payment.
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.plan,
    required this.transactionId,
  });

  final double amount;
  final String plan;
  final String transactionId;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _loading = true;
  bool _paid = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final result = await ChipService.getPurchaseStatus(widget.transactionId);
    if (!mounted) return;
    final status = result['status']?.toString().toLowerCase();
    setState(() {
      _loading = false;
      _paid =
          result['success'] == true &&
          const {'paid', 'completed', 'success'}.contains(status);
      if (!_paid) {
        _message =
            result['error']?.toString() ??
            (status == 'failed' || status == 'cancelled'
                ? 'Payment was not completed.'
                : 'Payment is still being confirmed. Retry in a moment.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              if (_loading)
                const CircularProgressIndicator(color: AeroColors.amber)
              else
                Icon(
                  _paid ? Icons.check_circle : Icons.schedule,
                  color: _paid ? AeroColors.success : AeroColors.amber,
                  size: 80,
                ),
              const SizedBox(height: 24),
              Text(
                _loading
                    ? 'Confirming payment'
                    : _paid
                    ? 'Payment confirmed'
                    : 'Confirmation pending',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loading
                    ? 'Waiting for secure server verification.'
                    : _paid
                    ? 'Your ${widget.plan} subscription is active.'
                    : _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AeroColors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text(
                'RM${widget.amount.toStringAsFixed(2)} • ${widget.transactionId}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AeroColors.greyLight),
              ),
              const Spacer(),
              if (!_loading && !_paid)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _verify,
                    child: const Text('Check payment again'),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Go to dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
