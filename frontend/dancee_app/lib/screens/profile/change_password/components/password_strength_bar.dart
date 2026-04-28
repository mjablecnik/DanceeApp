import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PasswordStrengthBar extends StatelessWidget {
  final int strength;

  const PasswordStrengthBar({super.key, required this.strength});

  Color _segmentColor(int index) {
    if (strength == 0 || index >= strength) return appBorder;
    switch (strength) {
      case 1:
        return appError;
      case 2:
        return appWarning;
      case 3:
        return appAmber;
      case 4:
        return appSuccess;
      default:
        return appBorder;
    }
  }

  String get _label {
    switch (strength) {
      case 1:
        return t.profile.changePassword.strengthVeryWeak;
      case 2:
        return t.profile.changePassword.strengthWeak;
      case 3:
        return t.profile.changePassword.strengthMedium;
      case 4:
        return t.profile.changePassword.strengthStrong;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: _segmentColor(i),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _label,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeSm,
          ),
        ),
      ],
    );
  }
}
