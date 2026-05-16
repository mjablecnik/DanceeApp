import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class AppCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: AppSizes.checkboxSize,
        height: AppSizes.checkboxSize,
        decoration: BoxDecoration(
          color: checked ? appPrimary : Colors.transparent,
          border: Border.all(
            color: checked ? appPrimary : appBorder,
            width: AppBorders.medium,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: checked
            ? const Center(
                child: FaIcon(FontAwesomeIcons.check, size: 10, color: appWhite),
              )
            : null,
      ),
    );
  }
}
