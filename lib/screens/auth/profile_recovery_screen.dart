import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/services/auth_service.dart';
import 'package:aerocrew/services/user_profile_service.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileRecoveryScreen extends StatefulWidget {
  const ProfileRecoveryScreen({
    super.key,
    required this.user,
    required this.onProfileCreated,
  });

  final User user;
  final VoidCallback onProfileCreated;

  @override
  State<ProfileRecoveryScreen> createState() => _ProfileRecoveryScreenState();
}

class _ProfileRecoveryScreenState extends State<ProfileRecoveryScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _profileService = UserProfileService();
  final _authService = AuthService();
  AppUserRole _role = AppUserRole.crew;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name and phone number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _profileService.createInitialProfile(
        authUser: widget.user,
        name: _nameController.text,
        phone: _phoneController.text,
        role: _role,
      );
      if (mounted) widget.onProfileCreated();
    } on ProfileFailure catch (error) {
      if (mounted) setState(() => _error = error.userMessage);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AeroAppBar(
        title: 'Complete account setup',
        subtitle: 'Recover your missing AeroCrew profile',
        showBackButton: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(AeroSpacing.screen),
            children: [
              AeroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.manage_accounts_outlined,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AeroSpacing.md),
                    Text(
                      'Authentication succeeded',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AeroSpacing.xs),
                    Text(
                      'Your Firebase account exists, but its AeroCrew profile is missing. Complete it without creating another account.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.aero.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AeroSpacing.section),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AeroSpacing.md),
              TextFormField(
                enabled: false,
                initialValue: widget.user.email,
                decoration: const InputDecoration(
                  labelText: 'Authenticated email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: AeroSpacing.md),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: AeroSpacing.section),
              Text(
                'Account type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AeroSpacing.sm),
              SegmentedButton<AppUserRole>(
                segments: const [
                  ButtonSegment(
                    value: AppUserRole.crew,
                    icon: Icon(Icons.flight_takeoff),
                    label: Text('Flight crew'),
                  ),
                  ButtonSegment(
                    value: AppUserRole.operator,
                    icon: Icon(Icons.airport_shuttle_outlined),
                    label: Text('Operator'),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: (selection) =>
                    setState(() => _role = selection.first),
              ),
              if (_error != null) ...[
                const SizedBox(height: AeroSpacing.md),
                Text(_error!, style: TextStyle(color: context.aero.danger)),
              ],
              const SizedBox(height: AeroSpacing.section),
              AeroButton(
                label: _loading ? 'Creating profile…' : 'Complete setup',
                expand: true,
                onPressed: _loading ? null : _createProfile,
              ),
              const SizedBox(height: AeroSpacing.sm),
              TextButton(
                onPressed: _loading ? null : _authService.signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
