import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/labels/section_label.dart';

class EditorFilterSection extends StatelessWidget {
  final String? publishedFilter;
  final String? reviewedFilter;
  final ValueChanged<String?> onPublishedFilterChanged;
  final ValueChanged<String?> onReviewedFilterChanged;

  const EditorFilterSection({
    super.key,
    required this.publishedFilter,
    required this.reviewedFilter,
    required this.onPublishedFilterChanged,
    required this.onReviewedFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title: t.editor.filter.publishedStatus),
        const SizedBox(height: AppSpacing.md),
        _FilterChipRow(
          options: [
            _FilterOption(label: t.editor.filter.all, value: null),
            _FilterOption(label: t.editor.published, value: 'published'),
            _FilterOption(label: t.editor.unpublished, value: 'unpublished'),
          ],
          selectedValue: publishedFilter,
          onSelected: onPublishedFilterChanged,
        ),
        const SizedBox(height: AppSpacing.xxl),
        SectionLabel(title: t.editor.filter.reviewedStatus),
        const SizedBox(height: AppSpacing.md),
        _FilterChipRow(
          options: [
            _FilterOption(label: t.editor.filter.all, value: null),
            _FilterOption(label: t.editor.reviewed, value: 'reviewed'),
            _FilterOption(label: t.editor.unreviewed, value: 'unreviewed'),
          ],
          selectedValue: reviewedFilter,
          onSelected: onReviewedFilterChanged,
        ),
      ],
    );
  }
}

class _FilterOption {
  final String label;
  final String? value;

  const _FilterOption({required this.label, required this.value});
}

class _FilterChipRow extends StatelessWidget {
  final List<_FilterOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const _FilterChipRow({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => onSelected(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? appPrimary : appSurface,
                border: Border.all(
                  color: isSelected ? appPrimary : appBorder,
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : appText,
                  fontSize: AppTypography.fontSizeSm,
                  fontWeight: isSelected
                      ? AppTypography.fontWeightSemiBold
                      : AppTypography.fontWeightMedium,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
