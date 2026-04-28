import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class DanceStyleCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const DanceStyleCard({
    super.key,
    required this.icon,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? appPrimary.withValues(alpha: 0.1) : appSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? appPrimary : appBorder,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 24,
              color: selected ? appPrimary : appMuted,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              style: TextStyle(
                color: selected ? appPrimary : appText,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
