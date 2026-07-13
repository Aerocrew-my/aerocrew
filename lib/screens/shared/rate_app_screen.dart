import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int selectedRating = 0;
  final feedbackController = TextEditingController();
  bool submitted = false;

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
                          color: AeroColors.divider,
                          width: 0.5,
                        ),
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
                        'RATE US',
                        style: TextStyle(
                          fontSize: 11,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Your feedback matters',
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
            ),
            Expanded(
              child: submitted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🙏', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          const Text(
                            'Thank you!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your feedback helps us improve AeroCrew for all aviation crew.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AeroColors.grey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AeroColors.amber,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AeroColors.amber,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.flight,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'How would you rate\nAeroCrew?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (i) => GestureDetector(
                                onTap: () =>
                                    setState(() => selectedRating = i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 52,
                                    color: i < selectedRating
                                        ? AeroColors.amber
                                        : AeroColors.divider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedRating == 0
                                ? 'Tap to rate'
                                : selectedRating == 5
                                ? 'Love it!'
                                : selectedRating >= 4
                                ? 'Really good'
                                : selectedRating >= 3
                                ? 'It\'s okay'
                                : 'Needs work',
                            style: TextStyle(
                              fontSize: 15,
                              color: selectedRating == 0
                                  ? AeroColors.grey
                                  : AeroColors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: feedbackController,
                            maxLines: 4,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Tell us what you love or what we can improve...',
                              hintStyle: const TextStyle(
                                color: AeroColors.grey,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: AeroColors.navyCard,
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
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selectedRating > 0
                                  ? () => setState(() => submitted = true)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AeroColors.amber,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AeroColors.navyCard,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Submit review',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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
