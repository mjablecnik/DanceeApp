import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../i18n/translations.g.dart';
import 'sections.dart';

part 'register_page.g.dart';

/// Route definition for the register page.
///
/// Uses [NoTransitionPage] to disable page transition animations.
@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: RegisterPage());
  }
}

/// Registration page with name, email, and password form fields,
/// social login options, and a link to the login page.
///
/// This is a placeholder implementation with no backend integration.
/// Structure based on .design/auth-register.html.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              RegisterHeaderSection(
                onBackPressed: () => context.pop(),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: const [
                        RegisterFormSection(),
                        SizedBox(height: 24),
                        RegisterButtonSection(),
                        SizedBox(height: 24),
                        LoginLinkSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
