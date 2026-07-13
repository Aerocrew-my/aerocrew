import 'package:aerocrew/screens/auth/signup_screen.dart';
import 'package:aerocrew/services/auth_service.dart';
import 'package:aerocrew/services/user_profile_service.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthService? _authInstance;
  UserProfileService? _profileInstance;

  AuthService get _auth => _authInstance ??= AuthService();
  UserProfileService get _profiles => _profileInstance ??= UserProfileService();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  User? _authenticatedUser;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _authenticatedUser = null;
    });
    try {
      final user = await _auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _authenticatedUser = user;
      await _loadProfile(user);
    } on AuthFailure catch (error) {
      if (mounted) setState(() => _error = error.userMessage);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _retryProfile() async {
    final user = _authenticatedUser ?? _auth.currentUser;
    if (user == null) {
      setState(() => _error = 'Your session ended. Sign in again.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _loadProfile(user);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadProfile(User user) async {
    try {
      await _profiles.load(user.uid);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ProfileFailure catch (failure) {
      if (!mounted) return;
      final debugDetail =
          kDebugMode && failure.code == ProfileFailureCode.permissionDenied
          ? ' Debug: Firestore denied users/${user.uid}; verify deployed rules and Firebase app selection.'
          : '';
      setState(() => _error = '${failure.userMessage}$debugDetail');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AeroAppBar(title: 'Sign in'),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AeroSpacing.screen),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: context.aero.blueSurface,
                          borderRadius: BorderRadius.circular(
                            AeroRadius.button,
                          ),
                        ),
                        child: Icon(
                          Icons.flight,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AeroSpacing.section),
                      Text(
                        'Welcome back',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AeroSpacing.xs),
                      Text(
                        'Use the email and password linked to your AeroCrew account.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.aero.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AeroSpacing.lg),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
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
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _loading ? null : _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
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
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter your password.'
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
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AeroSpacing.section),
                      AeroButton(
                        label: _loading ? 'Please wait…' : 'Sign in',
                        expand: true,
                        onPressed: _loading ? null : _login,
                      ),
                      if (_authenticatedUser != null && _error != null) ...[
                        const SizedBox(height: AeroSpacing.xs),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _loading ? null : _retryProfile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry profile loading'),
                          ),
                        ),
                      ],
                      const SizedBox(height: AeroSpacing.section),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to AeroCrew?',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  ),
                            child: const Text('Create account'),
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
