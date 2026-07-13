import 'package:aerocrew/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum ProfileFailureCode {
  permissionDenied,
  unavailable,
  unauthenticated,
  deadlineExceeded,
  malformed,
  unknown,
}

class ProfileFailure implements Exception {
  const ProfileFailure(this.code, this.userMessage);
  final ProfileFailureCode code;
  final String userMessage;
}

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AppUser?> load(String uid) async {
    try {
      final document = await _firestore.collection('users').doc(uid).get();
      if (!document.exists) return null;
      return AppUser.fromDocument(document);
    } on AppUserFormatException catch (error, stackTrace) {
      debugPrint('Malformed user profile for $uid: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      throw const ProfileFailure(
        ProfileFailureCode.malformed,
        'Your account profile needs support before it can be opened.',
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Firestore profile read failed [${error.code}] for $uid: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw _mapFailure(error);
    }
  }

  Future<AppUser> createInitialProfile({
    required User authUser,
    required String name,
    required String phone,
    required AppUserRole role,
  }) async {
    final email = authUser.email;
    if (email == null || email.isEmpty) {
      throw const ProfileFailure(
        ProfileFailureCode.malformed,
        'This account does not have a usable email address.',
      );
    }
    try {
      final reference = _firestore.collection('users').doc(authUser.uid);
      await reference.set({
        'name': name.trim(),
        'email': email,
        'phone': phone.trim(),
        'role': role.name,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      final created = await reference.get();
      return AppUser.fromDocument(created);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Firestore profile creation failed [${error.code}] for ${authUser.uid}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw _mapFailure(error);
    }
  }

  ProfileFailure _mapFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const ProfileFailure(
        ProfileFailureCode.permissionDenied,
        'Your account profile cannot be accessed right now.',
      ),
      'unavailable' => const ProfileFailure(
        ProfileFailureCode.unavailable,
        'Profile service is temporarily unavailable. Your sign-in is still active.',
      ),
      'unauthenticated' => const ProfileFailure(
        ProfileFailureCode.unauthenticated,
        'Your session needs to be refreshed. Sign in again.',
      ),
      'deadline-exceeded' => const ProfileFailure(
        ProfileFailureCode.deadlineExceeded,
        'Profile loading took too long. Check your connection and retry.',
      ),
      _ => const ProfileFailure(
        ProfileFailureCode.unknown,
        'Your profile could not be loaded. Your sign-in is still active.',
      ),
    };
  }
}
