import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
