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
      height: 256,
      child: Stack(
        children: [
          AppCachedImage(
            imageUrl: imageUrl,
            height: 256,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
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
        width: 40,
        height: 40,
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
        color: appPrimary.withValues(alpha: 0.9),
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
        color: appSurface.withValues(alpha: 0.9),
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
