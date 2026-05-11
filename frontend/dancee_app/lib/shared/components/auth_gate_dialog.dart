import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/service_locator.dart';
import '../../core/theme.dart';
import '../../i18n/strings.g.dart';
import '../../services/destination_service.dart';
import '../elements/buttons/gradient_button.dart';
import '../elements/buttons/text_link_button.dart';

Future<void> showAuthGateDialog(BuildContext context, {String? returnRoute}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: appBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => AuthGateBottomSheet(returnRoute: returnRoute),
  );
}

class AuthGateBottomSheet extends StatelessWidget {
  const AuthGateBottomSheet({super.key, this.returnRoute});

  final String? returnRoute;

  void _navigateToLogin(BuildContext context) {
    if (returnRoute != null) {
      sl<DestinationService>().setDestination(returnRoute!);
    }
    Navigator.of(context).pop();
    context.push('/login');
  }

  void _navigateToRegister(BuildContext context) {
    if (returnRoute != null) {
      sl<DestinationService>().setDestination(returnRoute!);
    }
    Navigator.of(context).pop();
    context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 48,
            color: appPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.authGate.actionMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
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
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
