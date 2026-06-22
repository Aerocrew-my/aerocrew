import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/auth/signup_screen.dart';
import 'package:aerocrew/screens/auth/login_screen.dart';

class OperatorOnboardingScreen extends StatefulWidget {
  const OperatorOnboardingScreen({super.key});

  @override
  State<OperatorOnboardingScreen> createState() =>
      _OperatorOnboardingScreenState();
}

class _OperatorOnboardingScreenState
    extends State<OperatorOnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final pages = [
    {
      'icon': Icons.verified_user,
      'color': Color(0xFF1D9E75),
      'title': 'Earn with verified crew',
      'subtitle':
          'Connect with airline pilots and cabin crew who need regular airport transport every month.',
      'highlight': 'Recurring monthly income',
    },
    {
      'icon': Icons.calendar_month,
      'color': Color(0xFFBA7517),
      'title': 'Advance schedule visibility',
      'subtitle':
          'See upcoming trips weeks in advance from crew rosters. Plan your schedule with confidence.',
      'highlight': 'No more uncertainty',
    },
    {
      'icon': Icons.payments_outlined,
      'color': Color(0xFF378ADD),
      'title': 'Weekly automated payouts',
      'subtitle':
          'Earnings are calculated automatically and transferred to your bank account every Monday.',
      'highlight': 'Transparent 15% commission',
    },
    {
      'icon': Icons.route,
      'color': Color(0xFFEF9F27),
      'title': 'AI route optimization',
      'subtitle':
          'Our AI calculates the most efficient pickup route for each job, saving you time and fuel.',
      'highlight': 'Smarter every trip',
    },
  ];

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AeroColors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_car,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text('AeroCrew Operators',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                    child: const Text('Skip',
                        style: TextStyle(
                            fontSize: 14, color: AeroColors.grey)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => currentPage = i),
                itemCount: pages.length,
                itemBuilder: (context, i) {
                  final page = pages[i];
                  final color = page['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(page['icon'] as IconData,
                              color: color, size: 48),
                        ),
                        const SizedBox(height: 40),
                        Text(page['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.2)),
                        const SizedBox(height: 16),
                        Text(page['subtitle'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AeroColors.grey,
                                height: 1.6)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: color.withValues(alpha: 0.3),
                                width: 0.5),
                          ),
                          child: Text(page['highlight'] as String,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? AeroColors.amber
                              : AeroColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage < pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AeroColors.amber,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                          currentPage < pages.length - 1
                              ? 'Next'
                              : 'Join as operator',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                    child: const Text(
                        'Already registered? Sign in',
                        style: TextStyle(
                            fontSize: 13, color: AeroColors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}