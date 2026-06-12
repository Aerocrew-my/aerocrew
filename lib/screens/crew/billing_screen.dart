import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AeroColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BILLING',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('Subscription & payments',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AeroColors.amber,
                            AeroColors.amber.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              const Text('AeroPool',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text('Active',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('RM750',
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const Text('per month',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70)),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Next renewal',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70)),
                                    Text('1 Jul 2026',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Zone',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70)),
                                    Text('Ara Damansara',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AeroColors.amber,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              side: const BorderSide(
                                  color: AeroColors.amber, width: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: const Text('Change plan',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AeroColors.danger,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              side: BorderSide(
                                  color: AeroColors.danger
                                      .withOpacity(0.5),
                                  width: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel plan',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('PAYMENT HISTORY',
                        style: AeroText.label),
                    const SizedBox(height: 10),
                    ...[
                      {
                        'month': 'June 2026',
                        'amount': 750.0,
                        'status': 'paid',
                        'method': 'FPX Maybank',
                        'date': '1 Jun 2026',
                      },
                      {
                        'month': 'May 2026',
                        'amount': 750.0,
                        'status': 'paid',
                        'method': 'FPX Maybank',
                        'date': '1 May 2026',
                      },
                      {
                        'month': 'April 2026',
                        'amount': 750.0,
                        'status': 'paid',
                        'method': 'FPX Maybank',
                        'date': '1 Apr 2026',
                      },
                    ].map((payment) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AeroColors.navyCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AeroColors.divider, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AeroColors.success
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.receipt_long,
                                    color: AeroColors.success,
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        payment['month'] as String,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                    Text(
                                        '${payment['method']} · ${payment['date']}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AeroColors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      'RM${(payment['amount'] as double).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AeroColors.success
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: const Text('Paid',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AeroColors.success,
                                            fontWeight:
                                                FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}