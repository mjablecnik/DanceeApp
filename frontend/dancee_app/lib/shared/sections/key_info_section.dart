import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class KeyInfoItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const KeyInfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class KeyInfoSection extends StatelessWidget {
  final List<KeyInfoItem> items;

  const KeyInfoSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _KeyInfoRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _KeyInfoRow extends StatelessWidget {
  final KeyInfoItem item;

  const _KeyInfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(item.icon, size: 18, color: appPrimary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: item.onTap != null ? appPrimary : appMuted,
                    fontSize: AppTypography.fontSizeMd,
                    decoration: item.onTap != null ? TextDecoration.underline : null,
                    decorationColor: item.onTap != null ? appPrimary : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
