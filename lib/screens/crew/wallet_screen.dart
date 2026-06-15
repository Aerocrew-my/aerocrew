import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  final double balance = 150.0;
  final double cashback = 23.50;

  final List<Map<String, dynamic>> transactions = const [
    {
      'type': 'cashback',
      'desc': 'Cashback — June AeroPool',
      'amount': 11.25,
      'date': '1 Jun 2026',
      'credit': true,
    },
    {
      'type': 'referral',
      'desc': 'Referral — Haziq Rahman subscribed',
      'amount': 50.0,
      'date': '12 Jun 2026',
      'credit': true,
    },
    {
      'type': 'referral',
      'desc': 'Referral — Kamarul Ariff subscribed',
      'amount': 50.0,
      'date': '5 Jun 2026',
      'credit': true,
    },
    {
      'type': 'redemption',
      'desc': 'Applied to May subscription',
      'amount': 50.0,
      'date': '1 May 2026',
      'credit': false,
    },
    {
      'type': 'cashback',
      'desc': 'Cashback — May AeroPool',
      'amount': 11.25,
      'date': '1 May 2026',
      'credit': true,
    },
    {
      'type': 'referral',
      'desc': 'Referral bonus — first signup',
      'amount': 50.0,
      'date': '15 Apr 2026',
      'credit': true,
    },
  ];

  IconData _txIcon(String type) {
    switch (type) {
      case 'cashback': return Icons.percent;
      case 'referral': return Icons.people_outline;
      case 'redemption': return Icons.redeem;
      default: return Icons.account_balance_wallet;
    }
  }

  Color _txColor(String type) {
    switch (type) {
      case 'cashback': return AeroColors.infoText;
      case 'referral': return AeroColors.success;
      case 'redemption': return AeroColors.amber;
      default: return AeroColors.grey;
    }
  }

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
                      Text('AEROCREW WALLET',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('Credits & cashback',
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
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildTransactionsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AeroColors.navyCard,
            AeroColors.amber.withOpacity(0.15)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AeroColors.amber.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AVAILABLE BALANCE',
              style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('RM${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AeroColors.navy.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.percent,
                              size: 12, color: AeroColors.infoText),
                          SizedBox(width: 4),
                          Text('Cashback',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AeroColors.grey)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('RM${cashback.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AeroColors.navy.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.people_outline,
                              size: 12, color: AeroColors.success),
                          SizedBox(width: 4),
                          Text('Referrals',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AeroColors.grey)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('RM${(balance - cashback).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: const Column(
              children: [
                Icon(Icons.redeem, color: AeroColors.amber, size: 22),
                SizedBox(height: 6),
                Text('Redeem',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                Text('Apply to next bill',
                    style: TextStyle(
                        fontSize: 10, color: AeroColors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: const Column(
              children: [
                Icon(Icons.share, color: AeroColors.success, size: 22),
                SizedBox(height: 6),
                Text('Refer friends',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                Text('Earn RM50 each',
                    style: TextStyle(
                        fontSize: 10, color: AeroColors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: const Column(
              children: [
                Icon(Icons.history, color: AeroColors.infoText, size: 22),
                SizedBox(height: 6),
                Text('History',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                Text('All transactions',
                    style: TextStyle(
                        fontSize: 10, color: AeroColors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TRANSACTION HISTORY', style: AeroText.label),
        const SizedBox(height: 10),
        ...transactions.map((tx) {
          final isCredit = tx['credit'] as bool;
          final color = _txColor(tx['type'] as String);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AeroColors.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_txIcon(tx['type'] as String),
                      color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['desc'] as String,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      Text(tx['date'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AeroColors.grey)),
                    ],
                  ),
                ),
                Text(
                    '${isCredit ? '+' : '-'}RM${(tx['amount'] as double).toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isCredit
                            ? AeroColors.success
                            : AeroColors.danger)),
              ],
            ),
          );
        }),
      ],
    );
  }
}