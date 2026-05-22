import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;

  static const _primaryBlue = Color(0xFF2946BE);
  static const _pageBackground = Color(0xFFF5F7FB);
  static const _textMuted = Color(0xFF5E6B7E);
  static const _fieldBorder = Color(0xFFDDE2EA);
  static const Map<String, _LoginCredential> _credentials = {
    'ssa@nvems.com': _LoginCredential(
      password: '123456',
      route: '/ssa/dashboard',
    ),
    'vtp@nvems.com': _LoginCredential(
      password: '123456',
      route: '/vtp-manager/dashboard',
    ),
    'vc@nvems.com': _LoginCredential(
      password: '123456',
      route: '/vc-coordinator/dashboard',
    ),
    'vt@nvems.com': _LoginCredential(
      password: '123456',
      route: '/vt-instructor/dashboard',
    ),
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final credential = _credentials[email];

    if (credential == null || credential.password != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(credential.route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 520;
            final horizontalPadding = isCompact ? 20.0 : 32.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isCompact ? 24 : 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      MediaQuery.of(context).padding.vertical -
                      (isCompact ? 48 : 32),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _BrandHeader(),
                        SizedBox(height: isCompact ? 28 : 32),
                        _LoginCard(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          rememberMe: _rememberMe,
                          obscurePassword: _obscurePassword,
                          onRememberChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onSignIn: _signIn,
                        ),
                        const SizedBox(height: 26),
                        Text(
                          '(c) 2026 SSA National Vocational Education '
                          'Management System',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _textMuted,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginCredential {
  const _LoginCredential({
    required this.password,
    required this.route,
  });

  final String password;
  final String route;
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _LoginPageState._primaryBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F2946BE),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'SSA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome to NVEMS',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'National Vocational Education Management System',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _LoginPageState._textMuted,
                fontSize: 16,
                letterSpacing: 0,
              ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 360;
        final cardPadding = isTight ? 22.0 : 32.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            cardPadding,
            isTight ? 28 : 34,
            cardPadding,
            32,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E6EE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1B2A4A),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Select your role and enter credentials',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _LoginPageState._textMuted,
                      fontSize: 14,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            const SizedBox(height: 28),
            const _FieldLabel('Email Address *'),
            const SizedBox(height: 10),
            _LoginTextField(
              controller: emailController,
              hintText: 'your.email@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Email address is required';
                }
                if (!text.contains('@')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            const _FieldLabel('Password *'),
            const SizedBox(height: 10),
            _LoginTextField(
              controller: passwordController,
              hintText: 'Enter your password',
              obscureText: obscurePassword,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF6D7788),
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
                const SizedBox(height: 18),
                if (isTight)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RememberMeControl(
                        rememberMe: rememberMe,
                        onRememberChanged: onRememberChanged,
                      ),
                      const SizedBox(height: 8),
                      _ForgotPasswordButton(onPressed: () {}),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _RememberMeControl(
                          rememberMe: rememberMe,
                          onRememberChanged: onRememberChanged,
                        ),
                      ),
                      _ForgotPasswordButton(onPressed: () {}),
                    ],
                  ),
                const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.login_rounded, size: 22),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _LoginPageState._primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0x552946BE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    "Don't have an account?",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _LoginPageState._textMuted,
                          fontSize: 14,
                          letterSpacing: 0,
                        ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: _LoginPageState._primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RememberMeControl extends StatelessWidget {
  const _RememberMeControl({
    required this.rememberMe,
    required this.onRememberChanged,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: rememberMe,
            onChanged: onRememberChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(color: Color(0xFF9AA3AF)),
            activeColor: _LoginPageState._primaryBlue,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Remember me',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF2F65FF),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF516071),
          fontSize: 15,
          letterSpacing: 0,
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 22,
          color: const Color(0xFF6D7788),
        ),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        errorMaxLines: 2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _LoginPageState._fieldBorder,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _LoginPageState._primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE25858),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE25858),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
