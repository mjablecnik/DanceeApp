import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/components/app_cached_image.dart';

class ProfilePhotoSection extends StatelessWidget {
  final String avatarUrl;
  final VoidCallback? onChangeTap;

  const ProfilePhotoSection({
    super.key,
    required this.avatarUrl,
    this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(color: appPrimary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: AppCachedImage(imageUrl: avatarUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onChangeTap,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: appPrimary,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: appBg, width: 2),
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.camera, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onChangeTap,
            child: Text(
              t.profile.editProfile.changePhoto,
              style: const TextStyle(
                color: appPrimary,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
