import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/service_locator.dart';
import '../../core/theme.dart';
import '../../i18n/strings.g.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../services/destination_service.dart';
import '../elements/buttons/gradient_button.dart';
import '../elements/buttons/text_link_button.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({
    super.key,
    required this.intendedRoute,
    this.showLogoutSuccess = false,
  });

  final String intendedRoute;
  final bool showLogoutSuccess;

  void _navigateToLogin(BuildContext context) {
    sl<DestinationService>().setDestination(intendedRoute);
    context.push('/login');
  }

  void _navigateToRegister(BuildContext context) {
    sl<DestinationService>().setDestination(intendedRoute);
    context.push('/register');
  }

  bool _isLogoutSuccess(BuildContext context) {
    if (showLogoutSuccess) return true;
    try {
      return context.read<AuthCubit>().didJustLogOut;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoutSuccess = _isLogoutSuccess(context);
    return ColoredBox(
      color: appBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                logoutSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.lock_outline_rounded,
                size: 72,
                color: appPrimary,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                logoutSuccess ? t.authGate.logoutTitle : t.authGate.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize4xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                logoutSuccess ? t.authGate.logoutMessage : t.authGate.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              GradientButton(
                label: t.authGate.login,
                onTap: () => _navigateToLogin(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextLinkButton(
                text: '',
                linkText: t.authGate.register,
                onLinkTap: () => _navigateToRegister(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
