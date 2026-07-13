import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aerocrew/constants.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  static const referralCode = 'AERO-FZ2026';
  bool codeCopied = false;

  final List<Map<String, dynamic>> referrals = [
    {
      'name': 'Haziq Rahman',
      'status': 'subscribed',
      'date': '12 Jun 2026',
      'reward': 50.0,
    },
    {
      'name': 'Nurul Ain',
      'status': 'signed_up',
      'date': '10 Jun 2026',
      'reward': 0.0,
    },
    {
      'name': 'Kamarul Ariff',
      'status': 'subscribed',
      'date': '5 Jun 2026',
      'reward': 50.0,
    },
  ];

  double get totalRewards =>
      referrals.fold(0, (s, r) => s + (r['reward'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),
                    _buildReferralCodeCard(context),
                    const SizedBox(height: 20),
                    _buildHowItWorks(),
                    const SizedBox(height: 20),
                    _buildReferralsList(),
                    const SizedBox(height: 20),
                    _buildShareButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REFERRAL PROGRAM',
                style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Earn with AeroCrew',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AeroColors.amber, AeroColors.amber.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          const Text(
            'Refer a crew member',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Earn RM50 for every crew member who subscribes using your code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRewardStat('${referrals.length}', 'Referred'),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildRewardStat(
                '${referrals.where((r) => r['status'] == 'subscribed').length}',
                'Subscribed',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildRewardStat(
                'RM${totalRewards.toStringAsFixed(0)}',
                'Earned',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          const Text('YOUR REFERRAL CODE', style: AeroText.label),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AeroColors.amber.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AeroColors.amber.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  referralCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AeroColors.amber,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: referralCode));
                    setState(() => codeCopied = true);
                    Future.delayed(
                      const Duration(seconds: 2),
                      () => setState(() => codeCopied = false),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: codeCopied
                          ? AeroColors.success.withValues(alpha: 0.12)
                          : AeroColors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: codeCopied
                            ? AeroColors.success.withValues(alpha: 0.3)
                            : AeroColors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          codeCopied ? Icons.check : Icons.copy_outlined,
                          size: 16,
                          color: codeCopied
                              ? AeroColors.success
                              : AeroColors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          codeCopied ? 'Copied!' : 'Copy code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: codeCopied
                                ? AeroColors.success
                                : AeroColors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      {
        'step': '1',
        'title': 'Share your code',
        'desc': 'Send your referral code to fellow crew members',
      },
      {
        'step': '2',
        'title': 'They sign up',
        'desc': 'They register using your referral code',
      },
      {
        'step': '3',
        'title': 'They subscribe',
        'desc': 'When they start a paid subscription',
      },
      {
        'step': '4',
        'title': 'You earn RM50',
        'desc': 'Credited to your AeroCrew wallet',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HOW IT WORKS', style: AeroText.label),
          const SizedBox(height: 12),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        s['step']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          s['desc']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AeroColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MY REFERRALS', style: AeroText.label),
        const SizedBox(height: 10),
        ...referrals.map(
          (r) => Container(
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
                    color: AeroColors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      (r['name'] as String).substring(0, 1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AeroColors.amber,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        r['date'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AeroColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: r['status'] == 'subscribed'
                            ? AeroColors.success.withValues(alpha: 0.1)
                            : AeroColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r['status'] == 'subscribed'
                            ? 'Subscribed'
                            : 'Signed up',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: r['status'] == 'subscribed'
                              ? AeroColors.success
                              : AeroColors.amber,
                        ),
                      ),
                    ),
                    if ((r['reward'] as double) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '+RM${(r['reward'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.share, size: 18),
        label: const Text(
          'Share my referral code',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AeroColors.amber,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
