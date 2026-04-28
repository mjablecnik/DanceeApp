import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../i18n/translations.g.dart';
import '../login/components.dart';
import '../login/login_page.dart';
import 'components.dart';

// ============================================================================
// RegisterHeaderSection
// ============================================================================

/// Gradient header with back button, app logo, title, and subtitle.
/// Matches the header from .design/auth-register.html.
class RegisterHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const RegisterHeaderSection({super.key, required this.onBackPressed});

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
            t.auth.registerTitle,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.auth.registerSubtitle,
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
// RegisterFormSection
// ============================================================================

/// Form section with name, email, and password input fields.
/// Placeholder implementation — no validation or backend calls.
class RegisterFormSection extends StatefulWidget {
  const RegisterFormSection({super.key});

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NameField(
          label: t.auth.name,
          placeholder: t.auth.namePlaceholder,
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }
}

// ============================================================================
// RegisterButtonSection
// ============================================================================

/// Register button and social login options (Google, Apple) with an "OR" divider.
class RegisterButtonSection extends StatelessWidget {
  const RegisterButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RegisterActionButton(),
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
// LoginLinkSection
// ============================================================================

/// "Already have an account? Sign In" link at the bottom of the register page.
class LoginLinkSection extends StatelessWidget {
  const LoginLinkSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${t.auth.alreadyHaveAccount} ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          GestureDetector(
            onTap: () => const LoginRoute().go(context),
            child: Text(
              t.auth.loginLink,
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
