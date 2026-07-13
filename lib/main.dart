import 'package:aerocrew/screens/auth/login_screen.dart';
import 'package:aerocrew/screens/shared/onboarding_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/theme/appearance_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    AppearanceController.instance.load(),
  ]);
  runApp(const AeroCrewApp());
}

class AeroCrewApp extends StatelessWidget {
  const AeroCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppearanceController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'AeroCrew',
          debugShowCheckedModeBanner: false,
          theme: AeroTheme.light,
          darkTheme: AeroTheme.dark,
          themeMode: AppearanceController.instance.themeMode,
          themeAnimationDuration: AeroMotion.standard,
          builder: (context, child) {
            final dark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: dark
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarColor: context.aero.surface,
                systemNavigationBarIconBrightness: dark
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarDividerColor: context.aero.border,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(AeroSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AeroSpacing.section),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.flight, color: Colors.white),
                      ),
                      const SizedBox(width: AeroSpacing.sm),
                      Text('AeroCrew', style: theme.textTheme.titleLarge),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AeroSpacing.md),
                  Text(
                    'Crew transport,\nready when you are.',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: AeroSpacing.sm),
                  Text(
                    'Plan roster-based pickups, follow live trips, and arrive ready for duty.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: context.aero.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AeroSpacing.lg),
                  _TrustPoint(
                    icon: Icons.verified_user_outlined,
                    title: 'Verified transport operators',
                    subtitle: 'Operator and vehicle documents are reviewed.',
                  ),
                  const SizedBox(height: AeroSpacing.sm),
                  _TrustPoint(
                    icon: Icons.calendar_month_outlined,
                    title: 'Roster-led planning',
                    subtitle:
                        'Turn confirmed duties into transport requirements.',
                  ),
                  const SizedBox(height: AeroSpacing.sm),
                  _TrustPoint(
                    icon: Icons.route_outlined,
                    title: 'Operational trip visibility',
                    subtitle:
                        'Assignment, driver, vehicle, and route in one place.',
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OnboardingScreen()),
                      ),
                      child: const Text('Get started'),
                    ),
                  ),
                  const SizedBox(height: AeroSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: AeroSpacing.xs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.aero.blueSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: AeroSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
