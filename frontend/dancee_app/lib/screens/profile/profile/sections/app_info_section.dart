import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/app_routes.dart';
import '../../../../core/colors.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../i18n/strings.g.dart';
import '../components/profile_menu_item.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

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
          FutureBuilder<String>(
            future: sl<ProfileRepository>().getAppVersion(),
            builder: (context, snapshot) {
              return ProfileMenuItem(
                icon: FontAwesomeIcons.circleInfo,
                iconBgColor: appBorder,
                iconColor: appMuted,
                title: t.profile.appInfo.version,
                trailing: Text(
                  snapshot.data ?? '',
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
                onTap: null,
                showDivider: true,
              );
            },
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.shieldHalved,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: t.profile.appInfo.termsOfUse,
            onTap: () => LegalPageRoute(
              slug: 'terms-of-use',
              title: t.profile.appInfo.termsOfUse,
            ).push(context),
            showDivider: true,
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.userShield,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: t.profile.appInfo.privacy,
            onTap: () => LegalPageRoute(
              slug: 'privacy-policy',
              title: t.profile.appInfo.privacy,
            ).push(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
