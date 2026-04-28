import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/entities/dance_style.dart';

class DanceStylesListSection extends StatelessWidget {
  final List<DanceStyle> styles;
  final Map<String, bool> selected; // key = dance style code
  final Map<String, int> counts; // key = dance style code, value = event count
  final ValueChanged<String> onToggle; // passes dance style code

  const DanceStylesListSection({
    super.key,
    required this.styles,
    required this.selected,
    required this.counts,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final visible = styles.where((s) => (counts[s.code] ?? 0) > 0).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(visible.length, (index) {
          final style = visible[index];
          final isLast = index == visible.length - 1;
          final isChecked = selected[style.code] ?? false;
          final count = counts[style.code] ?? 0;
          return _StyleRow(
            style: style,
            isChecked: isChecked,
            isLast: isLast,
            count: count,
            onToggle: () => onToggle(style.code),
          );
        }),
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  final DanceStyle style;
  final bool isChecked;
  final bool isLast;
  final int count;
  final VoidCallback onToggle;

  const _StyleRow({
    required this.style,
    required this.isChecked,
    required this.isLast,
    required this.count,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: appBorder)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.music, color: appPrimary, size: 16),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '${style.name} ($count)',
                style: const TextStyle(
                  fontSize: AppTypography.fontSizeXl,
                  fontWeight: AppTypography.fontWeightSemiBold,
                  color: appText,
                ),
              ),
            ),
            _Checkbox(isChecked: isChecked, onToggle: onToggle),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onToggle;

  const _Checkbox({required this.isChecked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? appPrimary : appSurface,
          border: Border.all(
            color: isChecked ? appPrimary : appBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: isChecked
            ? const Icon(FontAwesomeIcons.check, size: 12, color: Colors.white)
            : null,
      ),
    );
  }
}
