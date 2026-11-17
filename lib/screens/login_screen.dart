import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brainsnack/providers/auth_provider.dart';
import 'package:brainsnack/providers/home_provider.dart';
import 'package:brainsnack/screens/home_screen.dart';
import 'package:brainsnack/widgets/custom_button.dart';
import 'package:brainsnack/widgets/gradient_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialRegisterMode = false});

  static const routeName = '/login';

  final bool initialRegisterMode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late bool _isRegisterMode = widget.initialRegisterMode;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = _isRegisterMode
        ? await authProvider.register(
            _usernameController.text,
            _passwordController.text,
          )
        : await authProvider.login(
            _usernameController.text,
            _passwordController.text,
          );

    if (!success || !mounted) {
      return;
    }

    await context.read<HomeProvider>().refresh();
    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<HomeProvider>().refresh();
        if (!context.mounted) {
          return;
        }
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      });
    }

    return Scaffold(
      body: GradientShell(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -40,
              child: _GlowOrb(
                diameter: 220,
                color: const Color(0xFFFF9F1C).withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -60,
              child: _GlowOrb(
                diameter: 260,
                color: const Color(0xFF1FC8A5).withValues(alpha: 0.18),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102033).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _BrandHeader(),
                          const SizedBox(height: 24),
                          _AuthModeSwitcher(
                            isRegisterMode: _isRegisterMode,
                            onChanged: _toggleMode,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isRegisterMode
                                ? 'Create your BrainSnack account'
                                : 'Welcome back to BrainSnack',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isRegisterMode
                                ? 'Track your streaks, compare scores, and jump into smarter daily challenges.'
                                : 'Log in to continue your quiz streak and climb the leaderboard.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70, height: 1.35),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 3) {
                                return 'Enter at least 3 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: _isRegisterMode
                                ? TextInputAction.next
                                : TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 4) {
                                return 'Use at least 4 characters.';
                              }
                              return null;
                            },
                          ),
                          if (_isRegisterMode) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: const Icon(
                                  Icons.verified_user_outlined,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match.';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (authProvider.errorMessage != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A1F2A),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFFF8A8A),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFFFB3B3),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFFFFD1D1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          CustomButton(
                            label: _isRegisterMode
                                ? 'Create account'
                                : 'Log in',
                            icon: _isRegisterMode
                                ? Icons.person_add_alt_1_rounded
                                : Icons.login_rounded,
                            isLoading: authProvider.isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 14),
                          Align(
                            child: TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isRegisterMode
                                    ? 'Already have an account? Log in'
                                    : 'Need an account? Register',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _BrandLogo(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BrainSnack',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tiny lessons. Fast wins. Better recall.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  static const _assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            _assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthModeSwitcher extends StatelessWidget {
  const _AuthModeSwitcher({
    required this.isRegisterMode,
    required this.onChanged,
  });

  final bool isRegisterMode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Login',
              selected: !isRegisterMode,
              onTap: isRegisterMode ? onChanged : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeChip(
              label: 'Register',
              selected: isRegisterMode,
              onTap: isRegisterMode ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1FC8A5) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF06111D) : Colors.white70,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 120, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}
