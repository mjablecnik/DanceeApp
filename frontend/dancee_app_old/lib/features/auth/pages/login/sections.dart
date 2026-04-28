import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../i18n/translations.g.dart';
import '../register/register_page.dart';
import 'components.dart';

// ============================================================================
// LoginHeaderSection
// ============================================================================

/// Gradient header with back button, app logo, title, and subtitle.
/// Matches the header from .design/auth-login.html.
class LoginHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const LoginHeaderSection({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBackPressed,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const AppLogoIcon(),
          const SizedBox(height: 16),
          Text(
            t.auth.loginTitle,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.auth.loginSubtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LoginFormSection
// ============================================================================

/// Form section with email and password input fields.
/// Placeholder implementation — no validation or backend calls.
class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmailField(
          label: t.auth.email,
          placeholder: t.auth.emailPlaceholder,
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: t.auth.password,
          placeholder: t.auth.passwordPlaceholder,
          obscureText: _obscurePassword,
          onToggleVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            t.auth.forgotPassword,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// LoginButtonSection
// ============================================================================

/// Login button and social login options (Google, Apple) with an "OR" divider.
class LoginButtonSection extends StatelessWidget {
  const LoginButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientActionButton(),
        const SizedBox(height: 24),
        const OrDivider(),
        const SizedBox(height: 24),
        SocialLoginButton(
          icon: Icons.g_mobiledata,
          label: t.auth.continueWithGoogle,
          iconColor: const Color(0xFFEA4335),
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          icon: Icons.apple,
          label: t.auth.continueWithApple,
          iconColor: Colors.black,
          onPressed: () {},
        ),
      ],
    );
  }
}

// ============================================================================
// RegisterLinkSection
// ============================================================================

/// "Don't have an account? Register" link at the bottom of the login page.
class RegisterLinkSection extends StatelessWidget {
  const RegisterLinkSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${t.auth.noAccount} ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          GestureDetector(
            onTap: () => const RegisterRoute().go(context),
            child: Text(
              t.auth.register,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
