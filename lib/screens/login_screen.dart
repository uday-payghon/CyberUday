import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../widgets/cyber_layout.dart';
import 'admin_login_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool androidPhone =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        MediaQuery.sizeOf(context).width < 720;

    return CyberLayout(
      heroTag: 'AUTHENTICATION NODE',
      title: 'Secure access for your cyber workspace.',
      subtitle:
          'Monitor your profile, keep your login path hardened, and use Google or email authentication with clear failure states.',
      sideNote: androidPhone
          ? _AndroidQuickNotes(
              items: const [
                ('Google login is connected to Firebase.'),
                ('Email login and signup show clear errors.'),
                ('Android layout is optimized for small screens.'),
              ],
            )
          : _InfoRail(
              items: const [
                ('01', 'Real-time auth state handling'),
                ('02', 'Google OAuth and email login'),
                ('03', 'Responsive layout for mobile, tablet, desktop'),
              ],
            ),
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign in', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Login, sign up, or open admin access from one security entry point.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              const _EntryTag(label: 'LOGIN', active: true),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _loading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                child: const _EntryTag(label: 'SIGN UP'),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _loading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminLoginScreen(),
                          ),
                        );
                      },
                child: const _EntryTag(label: 'ADMIN'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty || !text.contains('@')) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text('Access Dashboard'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text('Continue with Google'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SecurityHintCard(androidPhone: androidPhone),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              Text('Need an account?', style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                child: const Text('Create one'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AndroidQuickNotes extends StatelessWidget {
  const _AndroidQuickNotes({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E4A67)),
        color: const Color(0xFF0B1823).withValues(alpha: 0.84),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick status',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF3FFFD7),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 8, color: Color(0xFF3FFFD7)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFF2F7FB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _EntryTag extends StatelessWidget {
  const _EntryTag({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active
            ? const Color(0xFF10273A)
            : const Color(0xFF0B1823).withValues(alpha: 0.78),
        border: Border.all(
          color: active ? const Color(0xFF3FFFD7) : const Color(0xFF1E4A67),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: active ? const Color(0xFF3FFFD7) : Colors.white,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SecurityHintCard extends StatelessWidget {
  const _SecurityHintCard({required this.androidPhone});

  final bool androidPhone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(androidPhone ? 12 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E4A67)),
        color: const Color(0xFF10273A).withValues(alpha: 0.40),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.verified_user_outlined, color: Color(0xFF3FFFD7)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Use the Firebase SHA and OAuth client you configured for this app. Google sign-in errors are now surfaced instead of hidden.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRail extends StatelessWidget {
  const _InfoRail({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: items
          .map(
            (item) => Container(
              constraints: const BoxConstraints(minWidth: 190, maxWidth: 240),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E4A67)),
                color: const Color(0xFF0B1823).withValues(alpha: 0.82),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF3FFFD7),
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.$2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFF2F7FB),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
