import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? expandedIndex;

  final List<Map<String, dynamic>> faqs = [
    {
      'q': 'How does AeroCrew match me with a van?',
      'a':
          'AeroCrew uses your home zone and flight departure time to group you with other crew flying from the same airport in a similar time window. Our AI clusters crew within 2-hour windows and assigns a verified PSV operator to the pool.',
      'icon': Icons.auto_awesome,
    },
    {
      'q': 'What if my roster changes last minute?',
      'a':
          'You can update your roster anytime. Cancellations made more than 48 hours before pickup are free. Late cancellations may incur a fee depending on your plan. Dynamic reassignment will find you a new pool automatically.',
      'icon': Icons.edit_calendar,
    },
    {
      'q': 'Are all operators verified?',
      'a':
          'Yes. Every operator must submit their SSM certificate, PSV licence, and LPKP operator permit before being activated. Our admin team manually reviews all documents. Operators are only visible to crew after full approval.',
      'icon': Icons.verified_user,
    },
    {
      'q': 'What is AeroPool, AeroFlex and AeroSolo?',
      'a':
          'AeroPool is a shared monthly subscription — most affordable. AeroFlex is pay-per-trip for standby or relief duties. AeroSolo is a private dedicated vehicle with no sharing, available as monthly or per-trip.',
      'icon': Icons.compare_arrows,
    },
    {
      'q': 'How do I cancel my subscription?',
      'a':
          'Go to Billing in your profile and tap Cancel plan. Your subscription remains active until the end of the current billing period. No refunds are issued for partial months.',
      'icon': Icons.cancel_outlined,
    },
    {
      'q': 'What payment methods are accepted?',
      'a':
          'We accept FPX online banking (Maybank, CIMB, RHB, etc.), Visa/Mastercard, Touch \'n Go eWallet, Boost, GrabPay, and Maybank QR. All payments are processed securely via CHIP Malaysia.',
      'icon': Icons.payment,
    },
    {
      'q': 'What if my van doesn\'t show up?',
      'a':
          'Contact the operator directly via the in-app call or WhatsApp button. If you cannot reach them, tap Report issue in the trip screen. AeroCrew will arrange an alternative and the operator will be reviewed.',
      'icon': Icons.warning_amber_outlined,
    },
    {
      'q': 'Can I use AeroCrew in Penang?',
      'a':
          'We are launching in Subang (SZB), KLIA, and klia2 first. Penang International Airport (PEN) is in Phase 2. Sign up now and we\'ll notify you when your airport goes live.',
      'icon': Icons.location_on_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildContactBanner(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: faqs.length,
                itemBuilder: (context, i) => _buildFaqItem(i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HELP & SUPPORT',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('Frequently asked questions',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AeroColors.amber.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AeroColors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.headset_mic,
                color: AeroColors.amber, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need more help?',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text('Email us at aerocrew.my@gmail.com',
                    style:
                        TextStyle(fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 13, color: AeroColors.amber),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final faq = faqs[index];
    final isExpanded = expandedIndex == index;

    return GestureDetector(
      onTap: () =>
          setState(() => expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded
              ? AeroColors.amber.withOpacity(0.06)
              : AeroColors.navyCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AeroColors.amber.withOpacity(0.3)
                : AeroColors.divider,
            width: isExpanded ? 1 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(faq['icon'] as IconData,
                    size: 16,
                    color: isExpanded ? AeroColors.amber : AeroColors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(faq['q'] as String,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isExpanded ? Colors.white : AeroColors.greyLight)),
                ),
                Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isExpanded ? AeroColors.amber : AeroColors.grey,
                    size: 18),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              const Divider(color: AeroColors.divider, height: 1),
              const SizedBox(height: 10),
              Text(faq['a'] as String,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AeroColors.greyLight,
                      height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}