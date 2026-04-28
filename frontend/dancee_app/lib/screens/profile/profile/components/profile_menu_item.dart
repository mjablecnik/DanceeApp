import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final double verticalPadding;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.trailing,
    this.onTap,
    required this.showDivider,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: verticalPadding,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(icon, size: 15, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeLg,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (trailing == null && onTap != null)
                    const FaIcon(FontAwesomeIcons.chevronRight, size: 13, color: appMuted),
                ],
              ),
            ),
            if (showDivider)
              const Divider(height: 1, color: appBorder, indent: 66),
          ],
        ),
      ),
    );
  }
}
