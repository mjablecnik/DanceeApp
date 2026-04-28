import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/profile_menu_item.dart';

class SupportSection extends StatelessWidget {
  final VoidCallback? onContactAuthor;
  final VoidCallback? onRateApp;

  const SupportSection({
    super.key,
    this.onContactAuthor,
    this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: FontAwesomeIcons.message,
            iconBgColor: appPrimary.withValues(alpha: 0.2),
            iconColor: appPrimary,
            title: t.profile.support.contactAuthor,
            onTap: onContactAuthor,
            showDivider: true,
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.star,
            iconBgColor: appGold.withValues(alpha: 0.2),
            iconColor: appGold,
            title: t.profile.support.rateApp,
            onTap: onRateApp,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
