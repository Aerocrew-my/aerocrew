import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double amount;
  final String plan;
  final String transactionId;

  const PaymentSuccessScreen({
    super.key,
    this.amount = 750.0,
    this.plan = 'AeroPool',
    this.transactionId = 'TXN-20260601-001',
  });

  @override
  State<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _recordPayment();
  }

  Future<void> _recordPayment() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection('payments').add({
        'userId': uid,
        'amount': widget.amount,
        'plan': widget.plan.toLowerCase(),
        'transactionId': widget.transactionId,
        'status': 'paid',
        'method': 'CHIP',
        'paidAt': FieldValue.serverTimestamp(),
      });
      // Update user subscription status
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'subscriptionStatus': 'active',
        'lastPaidAt': FieldValue.serverTimestamp(),
        'nextRenewal': DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          1,
        ).toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error recording payment: $e');
    }
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
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AeroColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AeroColors.success, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Payment successful!',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(
                  'Your ${widget.plan} subscription is now active.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AeroColors.grey,
                      height: 1.5)),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AeroColors.divider, width: 0.5),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Plan', widget.plan),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Amount',
                        'RM${widget.amount.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Valid until',
                        '${DateTime.now().month == 12 ? 'Jan' : _monthName(DateTime.now().month + 1)} ${DateTime.now().month == 12 ? DateTime.now().year + 1 : DateTime.now().year}'),
                    const SizedBox(height: 12),
                    Divider(color: AeroColors.divider, height: 1),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Transaction ID',
                        widget.transactionId.length > 20
                            ? '${widget.transactionId.substring(0, 20)}...'
                            : widget.transactionId,
                        valueColor: AeroColors.grey),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Payment gateway', 'CHIP Malaysia',
                        valueColor: AeroColors.grey),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AeroColors.amber,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Go to dashboard',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Download receipt',
                    style: TextStyle(
                        color: AeroColors.amber, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  Widget _buildReceiptRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AeroColors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white)),
      ],
    );
  }
}