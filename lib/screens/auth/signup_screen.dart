import 'package:aerocrew/models/app_user.dart';
import 'package:aerocrew/screens/auth/login_screen.dart';
import 'package:aerocrew/screens/auth/otp_screen.dart';
import 'package:aerocrew/services/auth_service.dart';
import 'package:aerocrew/services/user_profile_service.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthService? _authInstance;
  UserProfileService? _profileInstance;

  AuthService get _auth => _authInstance ??= AuthService();
  UserProfileService get _profiles => _profileInstance ??= UserProfileService();

  AppUserRole _role = AppUserRole.crew;
  User? _pendingProfileUser;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _pendingProfileUser = null;
    });
    try {
      User? user;
      try {
        user = await _auth.createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on AuthFailure catch (failure) {
        if (failure.code != AuthFailureCode.emailAlreadyInUse) rethrow;
        user = await _recoverExistingAuthAccount(failure);
      }
      if (user == null) return;
      await _createProfile(user);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.userMessage);
    } on ProfileFailure catch (failure) {
      if (mounted) setState(() => _error = failure.userMessage);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<User?> _recoverExistingAuthAccount(AuthFailure originalFailure) async {
    try {
      final user = await _auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final existingProfile = await _profiles.load(user.uid);
      if (existingProfile != null) {
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        return null;
      }
      return user;
    } on ProfileFailure {
      rethrow;
    } on AuthFailure {
      throw originalFailure;
    }
  }

  Future<void> _createProfile(User user) async {
    try {
      await _profiles.createInitialProfile(
        authUser: user,
        name: _nameController.text,
        phone: _phoneController.text,
        role: _role,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpScreen(phone: _phoneController.text.trim(), role: _role.name),
        ),
      );
    } on ProfileFailure catch (failure) {
      if (!mounted) return;
      final debugDetail =
          kDebugMode && failure.code == ProfileFailureCode.permissionDenied
          ? ' Debug: Firestore denied profile creation. Review the deployed users/{uid} create rule.'
          : '';
      setState(() {
        _pendingProfileUser = user;
        _error =
            '${failure.userMessage}$debugDetail Your Firebase account remains signed in; retrying will not create a duplicate.';
      });
    }
  }

  Future<void> _retryProfileCreation() async {
    final user = _pendingProfileUser ?? _auth.currentUser;
    if (user == null) {
      setState(
        () => _error = 'Your session ended. Sign in to recover this account.',
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _createProfile(user);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AeroAppBar(title: 'Create account'),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AeroSpacing.screen),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join AeroCrew',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AeroSpacing.xs),
                      Text(
                        'Create a crew or transport operator account. Administrative accounts cannot be created here.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.aero.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AeroSpacing.section),
                      Text('Account type', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AeroSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<AppUserRole>(
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
                          onSelectionChanged: _loading
                              ? null
                              : (selection) =>
                                    setState(() => _role = selection.first),
                        ),
                      ),
                      const SizedBox(height: AeroSpacing.section),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your full name.'
                            : null,
                      ),
                      const SizedBox(height: AeroSpacing.md),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@airline.com',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Enter your email address.';
                          }
                          if (!email.contains('@')) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AeroSpacing.md),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your phone number.'
                            : null,
                      ),
                      const SizedBox(height: AeroSpacing.md),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _loading ? null : _signup(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText: 'At least 8 characters',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 8
                            ? 'Use at least 8 characters.'
                            : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AeroSpacing.md),
                        AeroCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: context.aero.danger,
                              ),
                              const SizedBox(width: AeroSpacing.sm),
                              Expanded(child: Text(_error!)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AeroSpacing.section),
                      AeroButton(
                        label: _loading ? 'Please wait…' : 'Create account',
                        expand: true,
                        onPressed: _loading ? null : _signup,
                      ),
                      if (_pendingProfileUser != null) ...[
                        const SizedBox(height: AeroSpacing.xs),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _loading ? null : _retryProfileCreation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry profile creation'),
                          ),
                        ),
                      ],
                      const SizedBox(height: AeroSpacing.section),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already registered?',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
