import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../i18n/translations.g.dart';

part 'settings_page.g.dart';

/// Route definition for the settings page.
///
/// Simple page (no folder) with [NoTransitionPage] to disable animations.
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: SettingsPage());
  }
}

/// Settings page displaying user profile, preferences, account, and app info.
///
/// Placeholder implementation based on `.design/settings.html` and
/// `.design/settings-change.html`. No backend integration.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SettingsHeaderSection(
            onBackPressed: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: const [
                ProfileSection(),
                SizedBox(height: 24),
                PreferencesSection(),
                SizedBox(height: 24),
                AccountSection(),
                SizedBox(height: 24),
                AppInfoSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Section
// ---------------------------------------------------------------------------

/// Gradient header with back button and settings title.
class SettingsHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const SettingsHeaderSection({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Row(
            children: [
              SettingsHeaderIconButton(
                icon: Icons.arrow_back,
                onPressed: onBackPressed,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      t.settingsPage.title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.settingsPage.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular icon button used in the settings header.
class SettingsHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SettingsHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Section
// ---------------------------------------------------------------------------

/// Section displaying user profile information with avatar, name, and email.
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          icon: Icons.person,
          title: t.settingsPage.profile,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const ProfileAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileName(name: t.settingsPage.profileName),
                        const SizedBox(height: 4),
                        ProfileEmail(email: t.settingsPage.profileEmail),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EditProfileButton(onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

/// Gradient circle avatar placeholder for the user profile.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 32),
    );
  }
}

/// Displays the user's name in the profile section.
class ProfileName extends StatelessWidget {
  final String name;

  const ProfileName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

/// Displays the user's email in the profile section.
class ProfileEmail extends StatelessWidget {
  final String email;

  const ProfileEmail({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Text(
      email,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.grey[600],
      ),
    );
  }
}

/// Button to edit the user profile.
class EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditProfileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              t.settingsPage.editProfile,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preferences Section
// ---------------------------------------------------------------------------

/// Section with language, theme, and notification preferences.
class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          icon: Icons.tune,
          title: t.settingsPage.preferences,
        ),
        const SizedBox(height: 12),
        PreferenceRow(
          icon: Icons.language,
          iconColor: const Color(0xFF3B82F6),
          iconBackgroundColor: const Color(0xFFDBEAFE),
          label: t.settingsPage.language,
          value: t.settingsPage.languageValue,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        PreferenceRow(
          icon: Icons.palette,
          iconColor: const Color(0xFF8B5CF6),
          iconBackgroundColor: const Color(0xFFEDE9FE),
          label: t.settingsPage.theme,
          value: t.settingsPage.themeValue,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        PreferenceRow(
          icon: Icons.notifications,
          iconColor: const Color(0xFFF59E0B),
          iconBackgroundColor: const Color(0xFFFEF3C7),
          label: t.settingsPage.notifications,
          value: t.settingsPage.notificationsEnabled,
          onTap: () {},
        ),
      ],
    );
  }
}

/// A single preference row with icon, label, value, and chevron.
class PreferenceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const PreferenceRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account Section
// ---------------------------------------------------------------------------

/// Section with account management options (password, privacy, delete).
class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          icon: Icons.shield,
          title: t.settingsPage.account,
        ),
        const SizedBox(height: 12),
        AccountActionRow(
          icon: Icons.lock,
          iconColor: const Color(0xFF6366F1),
          iconBackgroundColor: const Color(0xFFEEF2FF),
          label: t.settingsPage.changePassword,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        AccountActionRow(
          icon: Icons.privacy_tip,
          iconColor: const Color(0xFF10B981),
          iconBackgroundColor: const Color(0xFFD1FAE5),
          label: t.settingsPage.privacySettings,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        DeleteAccountRow(onTap: () {}),
      ],
    );
  }
}

/// A single account action row with icon, label, and chevron.
class AccountActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final VoidCallback onTap;

  const AccountActionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

/// Delete account row with red danger styling.
class DeleteAccountRow extends StatelessWidget {
  final VoidCallback onTap;

  const DeleteAccountRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF2F2), Color(0xFFFFF1F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settingsPage.deleteAccount,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.settingsPage.deleteAccountWarning,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFEF4444), size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App Info Section
// ---------------------------------------------------------------------------

/// Section displaying app version, about, terms, and privacy links.
class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          icon: Icons.info_outline,
          title: t.settingsPage.appInfo,
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          icon: Icons.new_releases,
          iconColor: const Color(0xFF6366F1),
          iconBackgroundColor: const Color(0xFFEEF2FF),
          label: t.settingsPage.version,
          value: '1.0.0',
        ),
        const SizedBox(height: 8),
        AppInfoActionRow(
          icon: Icons.music_note,
          iconColor: const Color(0xFFEC4899),
          iconBackgroundColor: const Color(0xFFFCE7F3),
          label: t.settingsPage.about,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        AppInfoActionRow(
          icon: Icons.description,
          iconColor: const Color(0xFF8B5CF6),
          iconBackgroundColor: const Color(0xFFEDE9FE),
          label: t.settingsPage.termsOfService,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        AppInfoActionRow(
          icon: Icons.security,
          iconColor: const Color(0xFF10B981),
          iconBackgroundColor: const Color(0xFFD1FAE5),
          label: t.settingsPage.privacyPolicy,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        AppInfoActionRow(
          icon: Icons.headset_mic,
          iconColor: const Color(0xFF3B82F6),
          iconBackgroundColor: const Color(0xFFDBEAFE),
          label: t.settingsPage.contactSupport,
          onTap: () {},
        ),
      ],
    );
  }
}

/// A row displaying a static info value (e.g., version number).
class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String value;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable row for app info actions (about, terms, privacy, support).
class AppInfoActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final VoidCallback onTap;

  const AppInfoActionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Components
// ---------------------------------------------------------------------------

/// Reusable header row for each settings section (icon + title).
class SettingsSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsSectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
