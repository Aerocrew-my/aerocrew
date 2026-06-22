import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/auth/signup_screen.dart';
import 'package:aerocrew/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.auto_awesome,
      'color': Color(0xFFBA7517),
      'title': 'Scan Your Roster',
      'subtitle':
          'Take a photo of your airline schedule and extract your flights in seconds',
      'highlight': 'Works with AirAsia, MAS, Batik Air and more',
    },
    {
      'icon': Icons.people,
      'color': Color(0xFF1D9E75),
      'title': 'Smart Zone Pooling',
      'subtitle':
          'Automatically matched with crew in your area going to the same airport at similar times.',
      'highlight': 'Save up to 70% vs e-Hailing',
    },
    {
      'icon': Icons.verified_user,
      'color': Color(0xFF378ADD),
      'title': 'Verified Operators Only',
      'subtitle':
          'Every operator is verified with SSM, PSV licence and operator permit before being activated.',
      'highlight': 'Your safety is our utmost priority',
    },
    {
      'icon': Icons.schedule,
      'color': Color(0xFFEF9F27),
      'title': 'Always On Time',
      'subtitle':
          'Pickup times calculated from your departure. Operators get your schedule weeks in advance.',
      'highlight': 'Never miss reporting-in again',
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
                        child: const Icon(Icons.flight,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text('AeroCrew',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
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
                controller: _pageController,
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
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.2)),
                        const SizedBox(height: 16),
                        Text(page['subtitle'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 15,
                                color: AeroColors.grey,
                                height: 1.6)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: color.withValues(alpha: 0.3), width: 0.5),
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
                          _pageController.nextPage(
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
                              : 'Get started',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                    child: const Text('Already have an account? Sign in',
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