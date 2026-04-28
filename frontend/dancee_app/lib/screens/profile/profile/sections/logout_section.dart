import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class LogoutSection extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const LogoutSection({
    super.key,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _DangerRow(
            icon: FontAwesomeIcons.rightFromBracket,
            title: t.profile.danger.logout,
            onTap: onLogout,
            showDivider: true,
          ),
          _DangerRow(
            icon: FontAwesomeIcons.trash,
            title: t.profile.danger.deleteAccount,
            onTap: onDeleteAccount,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _DangerRow({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: appError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 15, color: appError),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: appError,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, color: appBorder, indent: 66),
        ],
      ),
    );
  }
}
