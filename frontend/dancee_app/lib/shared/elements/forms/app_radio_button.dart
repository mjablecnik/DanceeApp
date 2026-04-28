import 'package:flutter/material.dart';
import '../../../core/colors.dart';

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
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? appPrimary : appBorder,
            width: 2,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
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
