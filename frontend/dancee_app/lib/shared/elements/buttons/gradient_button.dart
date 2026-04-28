import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.primaryLg],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: AppTypography.fontWeightBold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
