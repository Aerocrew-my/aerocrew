import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class RateTripScreen extends StatefulWidget {
  const RateTripScreen({super.key});

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  int selectedRating = 0;
  final commentController = TextEditingController();
  bool submitted = false;

  final List<String> quickTags = [
    'On time',
    'Clean vehicle',
    'Friendly driver',
    'Safe driving',
    'Good route',
    'Professional',
  ];
  List<String> selectedTags = [];

  void _submit() {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }
    setState(() => submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (submitted) {
      return Scaffold(
        backgroundColor: AeroColors.navy,
        body: SafeArea(
          child: Center(
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
                    'Thanks for your feedback!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your rating helps us maintain quality for all AeroCrew members.',
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
                        'Back to dashboard',
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
        ),
      );
    }

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
                        'RATE YOUR TRIP',
                        style: TextStyle(
                          fontSize: 11,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'How was your ride?',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AeroColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AeroColors.amberLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: AeroColors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ahmad Hassan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Toyota Hiace · WXY 1234',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AeroColors.grey,
                                  ),
                                ),
                                Text(
                                  'AK6101 · Mon 16 Jun',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AeroColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('TAP TO RATE', style: AeroText.label),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedRating = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.star_rounded,
                              size: 48,
                              color: i < selectedRating
                                  ? AeroColors.amber
                                  : AeroColors.divider,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedRating == 0
                          ? 'Select a rating'
                          : selectedRating == 5
                          ? 'Excellent!'
                          : selectedRating == 4
                          ? 'Good'
                          : selectedRating == 3
                          ? 'Okay'
                          : selectedRating == 2
                          ? 'Poor'
                          : 'Very poor',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedRating == 0
                            ? AeroColors.grey
                            : AeroColors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('QUICK TAGS', style: AeroText.label),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickTags.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedTags.remove(tag);
                              } else {
                                selectedTags.add(tag);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AeroColors.amber.withValues(alpha: 0.15)
                                  : AeroColors.navyCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AeroColors.amber
                                    : AeroColors.divider,
                                width: isSelected ? 1 : 0.5,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AeroColors.amber
                                    : AeroColors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ADDITIONAL COMMENTS', style: AeroText.label),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Optional — tell us more...',
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
                        onPressed: _submit,
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
                          'Submit rating',
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
