import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/screens/auth/product_selection_screen.dart';
import 'package:aerocrew/screens/crew/crew_dashboard_screen.dart';
import 'package:aerocrew/screens/crew/crew_profile_screen.dart';
import 'package:aerocrew/screens/operator/operator_dashboard_screen.dart';
import 'package:aerocrew/screens/operator/operator_documents_screen.dart';
import 'package:aerocrew/screens/operator/operator_pending_screen.dart';
import 'package:aerocrew/screens/operator/operator_profile_screen.dart';
import 'package:flutter/material.dart';

class AuthenticatedDestination extends StatelessWidget {
  const AuthenticatedDestination({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    return switch (profile.role) {
      AppUserRole.crew when profile.product == null =>
        const ProductSelectionScreen(),
      AppUserRole.crew when !profile.profileComplete =>
        const CrewProfileScreen(),
      AppUserRole.crew => const CrewDashboardScreen(),
      AppUserRole.operator when !profile.profileComplete =>
        const OperatorProfileScreen(),
      AppUserRole.operator when !profile.documentsSubmitted =>
        const OperatorDocumentsScreen(),
      AppUserRole.operator when profile.isApprovedOperator =>
        const OperatorDashboardScreen(),
      AppUserRole.operator => const OperatorPendingScreen(),
    };
  }
}
