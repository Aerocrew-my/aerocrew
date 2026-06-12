import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() =>
      _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final Set<int> availableDays = {16, 17, 18, 20, 21, 23, 24, 25};
  final Set<int> blockedDays = {19, 22};
  int currentMonth = 6;
  int currentYear = 2026;

  final daysInMonth = 30;
  final firstDayOfWeek = 1; // Monday

  String get monthName {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[currentMonth]} $currentYear';
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
                      Text('AVAILABILITY',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('Set your schedule',
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AeroColors.divider, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  if (currentMonth == 1) {
                                    currentMonth = 12;
                                    currentYear--;
                                  } else {
                                    currentMonth--;
                                  }
                                }),
                                child: const Icon(
                                    Icons.chevron_left,
                                    color: AeroColors.grey),
                              ),
                              Text(monthName,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              GestureDetector(
                                onTap: () => setState(() {
                                  if (currentMonth == 12) {
                                    currentMonth = 1;
                                    currentYear++;
                                  } else {
                                    currentMonth++;
                                  }
                                }),
                                child: const Icon(
                                    Icons.chevron_right,
                                    color: AeroColors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                .map((d) => SizedBox(
                                      width: 36,
                                      child: Text(d,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AeroColors.grey,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                            ),
                            itemCount:
                                daysInMonth + firstDayOfWeek - 1,
                            itemBuilder: (context, index) {
                              if (index < firstDayOfWeek - 1) {
                                return const SizedBox();
                              }
                              final day =
                                  index - firstDayOfWeek + 2;
                              final isAvailable =
                                  availableDays.contains(day);
                              final isBlocked =
                                  blockedDays.contains(day);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isAvailable) {
                                      availableDays.remove(day);
                                      blockedDays.add(day);
                                    } else if (isBlocked) {
                                      blockedDays.remove(day);
                                    } else {
                                      availableDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? AeroColors.success
                                            .withOpacity(0.2)
                                        : isBlocked
                                            ? AeroColors.danger
                                                .withOpacity(0.15)
                                            : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isAvailable
                                          ? AeroColors.success
                                              .withOpacity(0.4)
                                          : isBlocked
                                              ? AeroColors.danger
                                                  .withOpacity(0.3)
                                              : Colors.transparent,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text('$day',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w500,
                                            color: isAvailable
                                                ? AeroColors.success
                                                : isBlocked
                                                    ? AeroColors
                                                        .danger
                                                    : AeroColors
                                                        .grey)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildLegend(
                            AeroColors.success, 'Available'),
                        const SizedBox(width: 16),
                        _buildLegend(AeroColors.danger, 'Unavailable'),
                        const SizedBox(width: 16),
                        _buildLegend(AeroColors.grey, 'Unset'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AeroColors.amber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AeroColors.amber.withOpacity(0.2),
                            width: 0.5),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AeroColors.amber, size: 16),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap a date to toggle availability. Crew are only matched with available operators.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AeroColors.amber,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text('Availability saved!'),
                                ],
                              ),
                              backgroundColor: AeroColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AeroColors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Save availability',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
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

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AeroColors.grey)),
      ],
    );
  }
}