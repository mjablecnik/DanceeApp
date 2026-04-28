import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/components/app_cached_image.dart';

class InstructorStat {
  final String value;
  final String label;

  const InstructorStat({required this.value, required this.label});
}

class InstructorCard extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String bio;
  final List<InstructorStat> stats;

  const InstructorCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.bio,
    this.stats = const [],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: AppCachedImage(
              imageUrl: avatarUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeXl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  bio,
                  style: const TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeMd,
                    height: 1.5,
                  ),
                ),
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      for (int i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.xxl),
                        Column(
                          children: [
                            Text(
                              stats[i].value,
                              style: const TextStyle(
                                color: appPrimary,
                                fontSize: AppTypography.fontSize2xl,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stats[i].label,
                              style: const TextStyle(
                                color: appMuted,
                                fontSize: AppTypography.fontSizeSm,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
