import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class SocialLinksSection extends StatelessWidget {
  final TextEditingController? instagramController;
  final TextEditingController? facebookController;

  const SocialLinksSection({
    super.key,
    this.instagramController,
    this.facebookController,
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
        children: [
          _SocialLinkField(
            label: t.profile.editProfile.instagram,
            icon: const FaIcon(FontAwesomeIcons.instagram, size: 16, color: appMuted),
            hintText: t.profile.editProfile.instagramHint,
            controller: instagramController,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SocialLinkField(
            label: t.profile.editProfile.facebook,
            icon: const FaIcon(FontAwesomeIcons.facebook, size: 16, color: appMuted),
            hintText: t.profile.editProfile.facebookHint,
            controller: facebookController,
          ),
        ],
      ),
    );
  }
}

class _SocialLinkField extends StatelessWidget {
  final String label;
  final Widget icon;
  final String hintText;
  final TextEditingController? controller;

  const _SocialLinkField({
    required this.label,
    required this.icon,
    required this.hintText,
    this.controller,
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
          Text(
            label,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              icon,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(color: appText),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hintText,
                    hintStyle: const TextStyle(color: appMuted),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
