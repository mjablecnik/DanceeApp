import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/background_circles.dart';
import '../../../shared/sections/auth_header_section.dart';
import 'sections/login_form_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Stack(
        children: [
          BackgroundCircles(animation: _floatAnim),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  AuthHeaderSection(
                    title: t.auth.login.title,
                    subtitle: t.auth.login.subtitle,
                  ),
                  const SizedBox(height: 48),
                  const LoginFormSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
