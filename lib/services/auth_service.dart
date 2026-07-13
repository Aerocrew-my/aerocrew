import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum AuthFailureCode {
  invalidEmail,
  invalidCredential,
  userDisabled,
  tooManyRequests,
  network,
  emailAlreadyInUse,
  weakPassword,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code, this.userMessage);
  final AuthFailureCode code;
  final String userMessage;
}

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Firebase Auth sign-in failed [${error.code}]: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw mapFirebaseAuthException(error);
    }
  }

  Future<User> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Firebase Auth signup failed [${error.code}]: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> signOut() => _auth.signOut();
}

/// Converts Firebase's implementation-specific error codes into stable,
/// user-safe failures that can be presented by the authentication UI.
AuthFailure mapFirebaseAuthException(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-email' => const AuthFailure(
      AuthFailureCode.invalidEmail,
      'Enter a valid email address.',
    ),
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' => const AuthFailure(
      AuthFailureCode.invalidCredential,
      'The email or password is incorrect.',
    ),
    'user-disabled' => const AuthFailure(
      AuthFailureCode.userDisabled,
      'This account has been disabled. Contact AeroCrew support.',
    ),
    'too-many-requests' => const AuthFailure(
      AuthFailureCode.tooManyRequests,
      'Too many attempts. Wait a moment before trying again.',
    ),
    'network-request-failed' => const AuthFailure(
      AuthFailureCode.network,
      'A network connection is required. Check your connection and retry.',
    ),
    'email-already-in-use' => const AuthFailure(
      AuthFailureCode.emailAlreadyInUse,
      'An account already exists for this email.',
    ),
    'weak-password' => const AuthFailure(
      AuthFailureCode.weakPassword,
      'Use a stronger password with at least 8 characters.',
    ),
    _ => const AuthFailure(
      AuthFailureCode.unknown,
      'Authentication is temporarily unavailable. Try again.',
    ),
  };
}
