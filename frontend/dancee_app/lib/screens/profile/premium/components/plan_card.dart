import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String? originalPrice;
  final String note;
  final String ctaLabel;
  final String? badge;
  final bool isPrimary;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    required this.note,
    required this.ctaLabel,
    this.badge,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  appPrimary.withValues(alpha: 0.1),
                  appAccent.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : appSurface,
        border: Border.all(
          color: isPrimary ? appPrimary.withValues(alpha: 0.3) : appBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPrimary) const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isPrimary)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.primary.createShader(bounds),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.fontSize6xl,
                          fontWeight: AppTypography.fontWeightBold,
                        ),
                      ),
                    ),
                    if (originalPrice != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        originalPrice!,
                        style: const TextStyle(
                          color: appMuted,
                          fontSize: AppTypography.fontSizeMd,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                )
              else
                Text(
                  price,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSize6xl,
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                note,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeSm,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                width: double.infinity,
                decoration: isPrimary
                    ? BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [AppShadows.primary],
                      )
                    : BoxDecoration(
                        color: appCard,
                        border: Border.all(color: appBorder),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                child: TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    ctaLabel,
                    style: TextStyle(
                      color: isPrimary ? Colors.white : appText,
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeXs,
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
