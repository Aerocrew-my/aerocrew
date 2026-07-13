import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/screens/auth/product_selection_screen.dart';
import 'package:aerocrew/screens/crew/crew_dashboard_screen.dart';
import 'package:aerocrew/screens/crew/crew_profile_screen.dart';
import 'package:aerocrew/screens/operator/operator_dashboard_screen.dart';
import 'package:aerocrew/screens/operator/operator_documents_screen.dart';
import 'package:aerocrew/screens/operator/operator_pending_screen.dart';
import 'package:aerocrew/screens/operator/operator_profile_screen.dart';
import 'package:flutter/material.dart';

enum AuthenticatedDestinationKind {
  profileRecovery,
  crewProductSelection,
  crewProfile,
  crewDashboard,
  operatorProfile,
  operatorDocuments,
  operatorPending,
  operatorDashboard,
}

AuthenticatedDestinationKind authenticatedDestinationFor(AppUser? profile) {
  if (profile == null) return AuthenticatedDestinationKind.profileRecovery;
  return switch (profile.role) {
    AppUserRole.crew when profile.product == null =>
      AuthenticatedDestinationKind.crewProductSelection,
    AppUserRole.crew when !profile.profileComplete =>
      AuthenticatedDestinationKind.crewProfile,
    AppUserRole.crew => AuthenticatedDestinationKind.crewDashboard,
    AppUserRole.operator when !profile.profileComplete =>
      AuthenticatedDestinationKind.operatorProfile,
    AppUserRole.operator when !profile.documentsSubmitted =>
      AuthenticatedDestinationKind.operatorDocuments,
    AppUserRole.operator when profile.isApprovedOperator =>
      AuthenticatedDestinationKind.operatorDashboard,
    AppUserRole.operator => AuthenticatedDestinationKind.operatorPending,
  };
}

class AuthenticatedDestination extends StatelessWidget {
  const AuthenticatedDestination({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    return switch (authenticatedDestinationFor(profile)) {
      AuthenticatedDestinationKind.profileRecovery => throw StateError(
        'AuthenticatedDestination requires a profile.',
      ),
      AuthenticatedDestinationKind.crewProductSelection =>
        const ProductSelectionScreen(),
      AuthenticatedDestinationKind.crewProfile => const CrewProfileScreen(),
      AuthenticatedDestinationKind.crewDashboard => const CrewDashboardScreen(),
      AuthenticatedDestinationKind.operatorProfile =>
        const OperatorProfileScreen(),
      AuthenticatedDestinationKind.operatorDocuments =>
        const OperatorDocumentsScreen(),
      AuthenticatedDestinationKind.operatorDashboard =>
        const OperatorDashboardScreen(),
      AuthenticatedDestinationKind.operatorPending =>
        const OperatorPendingScreen(),
    };
  }
}
