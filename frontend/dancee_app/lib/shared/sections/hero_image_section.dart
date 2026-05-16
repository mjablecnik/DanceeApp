import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../components/app_cached_image.dart';
import '../../core/theme.dart';

class HeroImageSection extends StatelessWidget {
  final String imageUrl;
  final Widget? topLeft;
  final Widget? topRight;

  const HeroImageSection({
    super.key,
    required this.imageUrl,
    this.topLeft,
    this.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.heroHeight,
      child: Stack(
        children: [
          AppCachedImage(
            imageUrl: imageUrl,
            height: AppSizes.heroHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: AppOpacity.low),
                  Colors.transparent,
                  appBg,
                ],
              ),
            ),
          ),
          if (topLeft != null)
            Positioned(
              top: AppSpacing.lg,
              left: AppSpacing.lg,
              child: topLeft!,
            ),
          if (topRight != null)
            Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: topRight!,
            ),
        ],
      ),
    );
  }
}

class HeroFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const HeroFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.iconButtonMd,
        height: AppSizes.iconButtonMd,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Center(
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class HeroPriceBadge extends StatelessWidget {
  final String price;

  const HeroPriceBadge({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: AppOpacity.high),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        price,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppTypography.fontSizeMd,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HeroLabelBadge extends StatelessWidget {
  final String label;

  const HeroLabelBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: appSurface.withValues(alpha: AppOpacity.high),
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: appText,
          fontSize: AppTypography.fontSizeMd,
          fontWeight: AppTypography.fontWeightMedium,
        ),
      ),
    );
  }
}
