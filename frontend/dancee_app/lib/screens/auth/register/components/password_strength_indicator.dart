import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;
  final bool isEmpty;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.isEmpty,
  });

  Color _strengthColor() {
    switch (strength) {
      case 0:
      case 1:
        return appError;
      case 2:
        return appAmber;
      default:
        return appSuccess;
    }
  }

  String _strengthLabel() {
    switch (strength) {
      case 0:
      case 1:
        return t.auth.passwordStrength.weak;
      case 2:
        return t.auth.passwordStrength.medium;
      case 3:
        return t.auth.passwordStrength.strong;
      default:
        return t.auth.passwordStrength.veryStrong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isEmpty ? appBorder : _strengthColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final filled = index < strength;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? AppSpacing.xs : 0),
                decoration: BoxDecoration(
                  color: filled ? color : appBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isEmpty ? t.auth.passwordStrength.hint : _strengthLabel(),
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            color: isEmpty ? appMuted : color,
          ),
        ),
      ],
    );
  }
}
