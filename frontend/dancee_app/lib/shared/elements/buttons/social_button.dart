import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

/// A styled social sign-in button (Google, Apple, etc.) used on auth screens.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: appBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeLg,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
