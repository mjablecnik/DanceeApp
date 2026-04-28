import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/components/app_cached_image.dart';
import '../components/dance_tag.dart';

class ProfileCardSection extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final List<({String label, Color color})> danceTags;

  const ProfileCardSection({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.danceTags,
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: appPrimary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AppCachedImage(imageUrl: avatarUrl, fit: BoxFit.cover),
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
                    fontSize: AppTypography.fontSize2xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  style: const TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: danceTags
                      .map((tag) => DanceTag(label: tag.label, color: tag.color))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
