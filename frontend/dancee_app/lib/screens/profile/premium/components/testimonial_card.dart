import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/components/app_cached_image.dart';

class TestimonialCard extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String quote;

  const TestimonialCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.round),
                child: AppCachedImage(
                  imageUrl: avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: List.generate(
                      5,
                      (i) => const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: FaIcon(
                          FontAwesomeIcons.solidStar,
                          size: 11,
                          color: appGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            quote,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
