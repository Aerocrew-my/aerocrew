import 'package:aerocrew/main.dart';
import 'package:aerocrew/firebase_options.dart';
import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/screens/auth/login_screen.dart';
import 'package:aerocrew/screens/auth/signup_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Firebase Android registration matches the application ID', () {
    expect(
      DefaultFirebaseOptions.android.appId,
      '1:791157275777:android:aa77725cc18692dbb92180',
    );
    expect(
      DefaultFirebaseOptions.web.appId,
      '1:791157275777:web:10196a6160bbf19bb92180',
    );
  });

  test('AppUser rejects unknown privileged roles', () {
    expect(
      () => AppUser.fromMap('uid', {
        'name': 'Admin',
        'email': 'admin@example.com',
        'phone': '+60000000000',
        'role': 'admin',
        'status': 'active',
      }),
      throwsA(isA<AppUserFormatException>()),
    );
  });

  test('AppUser only approves explicit operator approval states', () {
    AppUser operator(String status) => AppUser.fromMap('uid', {
      'name': 'Operator',
      'email': 'operator@example.com',
      'phone': '+60000000000',
      'role': 'operator',
      'status': status,
      'profileComplete': true,
      'documentsSubmittedAt': DateTime(2026),
    });

    expect(operator('pending').isApprovedOperator, isFalse);
    expect(operator('pending_verification').isApprovedOperator, isFalse);
    expect(operator('verified').isApprovedOperator, isTrue);
    expect(operator('approved').isApprovedOperator, isTrue);
  });

  testWidgets('public splash renders with Skyline theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AeroTheme.light, home: const SplashScreen()),
    );
    expect(find.text('AeroCrew'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Login and Signup render in ${mode.name} mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AeroTheme.light,
          darkTheme: AeroTheme.dark,
          themeMode: mode,
          home: const LoginScreen(),
        ),
      );
      expect(find.text('Welcome back'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AeroTheme.light,
          darkTheme: AeroTheme.dark,
          themeMode: mode,
          home: const SignupScreen(),
        ),
      );
      await tester.pump();
      expect(find.text('Join AeroCrew'), findsOneWidget);
    });
  }
}
