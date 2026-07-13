import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String selectedCategory = 'general';
  final messageController = TextEditingController();
  bool submitted = false;

  final List<Map<String, dynamic>> faqs = [
    {
      'q': 'How does AeroPool matching work?',
      'a':
          'Our AI groups crew in the same residential zone with flights departing within a 1–2 hour window. Pickup times are calculated 2.5 hours before departure.',
      'open': false,
    },
    {
      'q': 'What if my roster changes last minute?',
      'a':
          'Upload your updated roster and the system will reassign you automatically. Cancellations within 4 hours of pickup may incur a fee.',
      'open': false,
    },
    {
      'q': 'How are operators verified?',
      'a':
          'Every operator submits SSM certificate, PSV licence and operator permit. Our team manually reviews and approves each operator before they go live.',
      'open': false,
    },
    {
      'q': 'When does my subscription renew?',
      'a':
          'Subscriptions renew on the 1st of every month. You will receive a reminder 3 days before renewal.',
      'open': false,
    },
    {
      'q': 'Can I cancel anytime?',
      'a':
          'Yes. Cancel before the 25th of the month to avoid the next renewal charge. Active trips will still be completed.',
      'open': false,
    },
    {
      'q': 'What airports are covered?',
      'a':
          'Currently Subang (SZB), KLIA and klia2. Penang International (PEN) is coming in Phase 2.',
      'open': false,
    },
  ];

  final categories = [
    {'id': 'general', 'label': 'General', 'icon': Icons.help_outline},
    {'id': 'payment', 'label': 'Payment', 'icon': Icons.credit_card},
    {'id': 'trip', 'label': 'Trip issue', 'icon': Icons.directions_car},
    {'id': 'account', 'label': 'Account', 'icon': Icons.person_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: submitted ? _buildSuccessView() : _buildContent()),
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
                'SUPPORT',
                style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Help & contact',
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactBanner(),
          const SizedBox(height: 20),
          const Text('FREQUENTLY ASKED', style: AeroText.label),
          const SizedBox(height: 10),
          _buildFAQSection(),
          const SizedBox(height: 20),
          const Text('SEND A MESSAGE', style: AeroText.label),
          const SizedBox(height: 10),
          _buildMessageForm(),
        ],
      ),
    );
  }

  Widget _buildContactBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AeroColors.amber.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AeroColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: AeroColors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live support available',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Mon–Fri 8am–10pm · Sat–Sun 8am–6pm',
                  style: TextStyle(fontSize: 11, color: AeroColors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 6, color: AeroColors.success),
                SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AeroColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      children: faqs.asMap().entries.map((entry) {
        final i = entry.key;
        final faq = entry.value;
        final isOpen = faq['open'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AeroColors.navyCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOpen
                  ? AeroColors.amber.withValues(alpha: 0.3)
                  : AeroColors.divider,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => faqs[i]['open'] = !isOpen),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq['q'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isOpen ? AeroColors.amber : AeroColors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Text(
                    faq['a'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AeroColors.grey,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageForm() {
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
          const Text('Category', style: AeroText.label),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => selectedCategory = cat['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AeroColors.amber.withValues(alpha: 0.15)
                          : AeroColors.navy,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AeroColors.amber
                            : AeroColors.divider,
                        width: isSelected ? 1 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 13,
                          color: isSelected
                              ? AeroColors.amber
                              : AeroColors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AeroColors.amber
                                : AeroColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Message', style: AeroText.label),
          const SizedBox(height: 8),
          TextField(
            controller: messageController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describe your issue...',
              hintStyle: const TextStyle(color: AeroColors.grey, fontSize: 13),
              filled: true,
              fillColor: AeroColors.navy,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AeroColors.divider,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AeroColors.divider,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AeroColors.amber,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (messageController.text.trim().isEmpty) return;
                setState(() => submitted = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AeroColors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send message',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AeroColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AeroColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Message sent!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our team will respond within 2 business hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AeroColors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AeroColors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
