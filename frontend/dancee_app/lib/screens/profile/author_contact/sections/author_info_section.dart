import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/theme.dart';
import '../../../../../i18n/strings.g.dart';

class AuthorInfoSection extends StatelessWidget {
  const AuthorInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.user, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.contact.teamName,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.bold,
                      color: appText,
                    ),
                  ),
                  Text(
                    t.contact.email,
                    style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.contact.description,
            style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
          ),
        ],
      ),
    );
  }
}
