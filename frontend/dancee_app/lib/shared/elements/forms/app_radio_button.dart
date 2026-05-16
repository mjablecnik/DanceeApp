import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class AppRadioButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const AppRadioButton({
    super.key,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.checkboxSize,
        height: AppSizes.checkboxSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? appPrimary : appBorder,
            width: AppBorders.medium,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: AppSizes.checkboxSize / 2,
                  height: AppSizes.checkboxSize / 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: appPrimary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
