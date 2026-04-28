import 'package:flutter/material.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/theme.dart';

class SubjectOption extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const SubjectOption({
    super.key,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: isSelected ? appPrimary : appBorder),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: (v) => onChanged(v ?? ''),
                activeColor: appPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appText),
            ),
          ],
        ),
      ),
    );
  }
}
