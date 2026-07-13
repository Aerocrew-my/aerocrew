import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/screens/auth/authenticated_destination.dart';
import 'package:aerocrew/screens/auth/profile_recovery_screen.dart';
import 'package:aerocrew/services/auth_service.dart';
import 'package:aerocrew/services/user_profile_service.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.unauthenticated});

  final Widget unauthenticated;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: AeroLoadingState(label: 'Checking your account'),
          );
        }
        final user = snapshot.data;
        if (user == null) return unauthenticated;
        return _AuthenticatedProfileLoader(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class _AuthenticatedProfileLoader extends StatefulWidget {
  const _AuthenticatedProfileLoader({super.key, required this.user});
  final User user;

  @override
  State<_AuthenticatedProfileLoader> createState() =>
      _AuthenticatedProfileLoaderState();
}

class _AuthenticatedProfileLoaderState
    extends State<_AuthenticatedProfileLoader> {
  final _profiles = UserProfileService();
  final _auth = AuthService();
  late Future<AppUser?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _profiles.load(widget.user.uid);
  }

  void _reload() {
    setState(() => _profile = _profiles.load(widget.user.uid));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: AeroLoadingState(label: 'Loading your AeroCrew profile'),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final failure = error is ProfileFailure ? error : null;
          final debugDetail =
              kDebugMode && failure?.code == ProfileFailureCode.permissionDenied
              ? '\n\nDebug: Firestore denied users/${widget.user.uid}. Review deployed rules and Firebase app configuration.'
              : '';
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(AeroSpacing.screen),
                    child: AeroErrorState(
                      message:
                          '${failure?.userMessage ?? 'Your profile could not be loaded.'}$debugDetail',
                      onRetry: _reload,
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: TextButton(
                onPressed: _auth.signOut,
                child: const Text('Sign out'),
              ),
            ),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return ProfileRecoveryScreen(
            user: widget.user,
            onProfileCreated: _reload,
          );
        }
        return AuthenticatedDestination(profile: profile);
      },
    );
  }
}
