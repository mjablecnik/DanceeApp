import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class SelectedStylesSection extends StatelessWidget {
  final List<String> selectedStyles;
  final ValueChanged<String> onRemove;

  const SelectedStylesSection({
    super.key,
    required this.selectedStyles,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.filter.selectedStyles,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightSemiBold,
            color: appMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: selectedStyles.map((style) => _SelectedTag(label: style, onRemove: () => onRemove(style))).toList(),
        ),
      ],
    );
  }
}

class _SelectedTag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectedTag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: 0.2),
        border: Border.all(color: appPrimary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightMedium,
              color: appPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(FontAwesomeIcons.xmark, size: 12, color: appPrimary),
          ),
        ],
      ),
    );
  }
}
