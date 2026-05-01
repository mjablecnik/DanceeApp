import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class BioSection extends StatelessWidget {
  final TextEditingController bioController;

  const BioSection({
    super.key,
    required this.bioController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.profile.editProfile.bio,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: TextField(
              controller: bioController,
              maxLines: 3,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeMd,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: t.profile.editProfile.bioHint,
                hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
