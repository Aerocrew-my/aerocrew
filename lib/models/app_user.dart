import 'package:cloud_firestore/cloud_firestore.dart';

enum AppUserRole {
  crew,
  operator;

  static AppUserRole? parse(Object? value) => switch (value) {
    'crew' => AppUserRole.crew,
    'operator' => AppUserRole.operator,
    _ => null,
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.profileComplete,
    required this.documentsSubmitted,
    this.product,
    this.onboardingStage,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final AppUserRole role;
  final String status;
  final bool profileComplete;
  final bool documentsSubmitted;
  final String? product;
  final String? onboardingStage;

  bool get isApprovedOperator =>
      role == AppUserRole.operator &&
      const {'approved', 'verified', 'active'}.contains(status.toLowerCase());

  factory AppUser.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw const AppUserFormatException('Profile data is missing.');
    }
    return AppUser.fromMap(document.id, data);
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    final role = AppUserRole.parse(data['role']);
    if (role == null) {
      throw const AppUserFormatException('Profile role is invalid.');
    }
    final name = data['name'];
    final email = data['email'];
    final phone = data['phone'];
    final status = data['status'];
    if (name is! String ||
        email is! String ||
        phone is! String ||
        status is! String) {
      throw const AppUserFormatException(
        'Profile contains invalid required fields.',
      );
    }
    final product = data['product'];
    final onboardingStage = data['onboardingStage'];
    if ((product != null && product is! String) ||
        (onboardingStage != null && onboardingStage is! String)) {
      throw const AppUserFormatException(
        'Profile contains invalid optional fields.',
      );
    }
    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      status: status,
      profileComplete: data['profileComplete'] == true,
      documentsSubmitted: data['documentsSubmittedAt'] != null,
      product: product as String?,
      onboardingStage: onboardingStage as String?,
    );
  }
}

class AppUserFormatException implements Exception {
  const AppUserFormatException(this.message);
  final String message;
}
