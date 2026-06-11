import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/auth/login_screen.dart';
import 'package:aerocrew/screens/auth/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AeroCrewApp());
}

class AeroCrewApp extends StatelessWidget {
  const AeroCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroCrew',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AeroColors.amber,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AeroColors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flight,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text('AeroCrew',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.3)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AeroDecoration.darkCard,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AeroColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_user,
                              color: AeroColors.amber, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Verified operators only',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              SizedBox(height: 2),
                              Text('SSM, PSV & permit checked',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AeroDecoration.darkCard,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AeroColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: AeroColors.success, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI-powered roster scan',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              SizedBox(height: 2),
                              Text('Photo to schedule in seconds',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AeroDecoration.darkCard,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AeroColors.infoText.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people,
                              color: AeroColors.infoText, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Smart pooling',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              SizedBox(height: 2),
                              Text('Auto-matched by zone & flight time',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Transport built\nfor aviation crew.',
                    style: AeroText.heading1.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reliable. Verified. Affordable.',
                    style: TextStyle(
                        fontSize: 15,
                        color: AeroColors.grey,
                        letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AeroColors.amber,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Get started',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AeroColors.greyLight,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: AeroColors.divider, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Sign in',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'SZB · KLIA · KLIA2 · PEN',
                      style: TextStyle(
                          fontSize: 12,
                          color: AeroColors.grey.withValues(alpha: 0.6),
                          letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}