import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/screens/auth/authenticated_destination.dart';
import 'package:aerocrew/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firebase Auth failure mapping', () {
    const expectedCodes = <String, AuthFailureCode>{
      'invalid-email': AuthFailureCode.invalidEmail,
      'invalid-credential': AuthFailureCode.invalidCredential,
      'user-not-found': AuthFailureCode.invalidCredential,
      'wrong-password': AuthFailureCode.invalidCredential,
      'user-disabled': AuthFailureCode.userDisabled,
      'too-many-requests': AuthFailureCode.tooManyRequests,
      'network-request-failed': AuthFailureCode.network,
      'email-already-in-use': AuthFailureCode.emailAlreadyInUse,
      'weak-password': AuthFailureCode.weakPassword,
    };

    for (final entry in expectedCodes.entries) {
      test('maps ${entry.key}', () {
        final failure = mapFirebaseAuthException(
          FirebaseAuthException(code: entry.key, message: 'raw backend detail'),
        );
        expect(failure.code, entry.value);
        expect(failure.userMessage, isNot(contains('raw backend detail')));
      });
    }

    test('maps unknown errors to a safe fallback', () {
      final failure = mapFirebaseAuthException(
        FirebaseAuthException(code: 'new-server-code', message: 'sensitive'),
      );
      expect(failure.code, AuthFailureCode.unknown);
      expect(failure.userMessage, isNot(contains('sensitive')));
    });
  });

  group('AppUser parsing', () {
    test('parses public roles and rejects unknown roles', () {
      expect(AppUserRole.parse('crew'), AppUserRole.crew);
      expect(AppUserRole.parse('operator'), AppUserRole.operator);
      expect(AppUserRole.parse('admin'), isNull);
      expect(AppUserRole.parse(null), isNull);
    });

    test('parses a valid profile', () {
      final profile = _profile(role: AppUserRole.crew, product: 'shared');
      expect(profile.id, 'uid');
      expect(profile.role, AppUserRole.crew);
      expect(profile.product, 'shared');
    });

    test('turns malformed optional fields into a format exception', () {
      expect(
        () => AppUser.fromMap('uid', {
          ..._baseProfile,
          'role': 'crew',
          'product': 42,
        }),
        throwsA(isA<AppUserFormatException>()),
      );
    });
  });

  group('authenticated destination decisions', () {
    test('a missing profile requires recovery', () {
      expect(
        authenticatedDestinationFor(null),
        AuthenticatedDestinationKind.profileRecovery,
      );
    });

    test('crew setup and dashboard decisions are explicit', () {
      expect(
        authenticatedDestinationFor(_profile(role: AppUserRole.crew)),
        AuthenticatedDestinationKind.crewProductSelection,
      );
      expect(
        authenticatedDestinationFor(
          _profile(role: AppUserRole.crew, product: 'shared'),
        ),
        AuthenticatedDestinationKind.crewProfile,
      );
      expect(
        authenticatedDestinationFor(
          _profile(
            role: AppUserRole.crew,
            product: 'shared',
            profileComplete: true,
          ),
        ),
        AuthenticatedDestinationKind.crewDashboard,
      );
    });

    test('operators never reach the dashboard before setup and approval', () {
      expect(
        authenticatedDestinationFor(_profile(role: AppUserRole.operator)),
        AuthenticatedDestinationKind.operatorProfile,
      );
      expect(
        authenticatedDestinationFor(
          _profile(role: AppUserRole.operator, profileComplete: true),
        ),
        AuthenticatedDestinationKind.operatorDocuments,
      );
      expect(
        authenticatedDestinationFor(
          _profile(
            role: AppUserRole.operator,
            profileComplete: true,
            documentsSubmitted: true,
            status: 'pending',
          ),
        ),
        AuthenticatedDestinationKind.operatorPending,
      );
      expect(
        authenticatedDestinationFor(
          _profile(
            role: AppUserRole.operator,
            profileComplete: true,
            documentsSubmitted: true,
            status: 'approved',
          ),
        ),
        AuthenticatedDestinationKind.operatorDashboard,
      );
    });
  });
}

const _baseProfile = <String, dynamic>{
  'name': 'Test User',
  'email': 'test@example.com',
  'phone': '+60123456789',
  'status': 'pending',
};

AppUser _profile({
  required AppUserRole role,
  String status = 'pending',
  String? product,
  bool profileComplete = false,
  bool documentsSubmitted = false,
}) {
  return AppUser.fromMap('uid', {
    ..._baseProfile,
    'role': role.name,
    'status': status,
    'product': product,
    'profileComplete': profileComplete,
    if (documentsSubmitted) 'documentsSubmittedAt': DateTime(2026),
  });
}
