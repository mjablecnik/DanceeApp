import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/user_repository.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/labels/section_label.dart';
import 'sections/bio_section.dart';
import 'sections/dance_preferences_section.dart';
import 'sections/experience_level_section.dart';
import 'sections/notifications_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/profile_photo_section.dart';
import 'sections/save_button_section.dart';
import 'sections/social_links_section.dart';

const _kDanceStyleNames = [
  'Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Reggaeton',
  'Tango', 'Swing', 'Ballroom', 'Afro', 'Forró',
];

const _kExperienceLevelNames = [
  'Začátečník', 'Mírně pokročilý', 'Pokročilý', 'Expert',
];

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late Map<String, bool> _dancePrefs;
  late String _level;
  late Map<String, bool> _notifications;
  late Map<String, String> _notificationSubtitles;
  bool _initialized = false;

  Future<UserData>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _notifications = {
      t.profile.editProfile.notifications.newEvents: true,
      t.profile.editProfile.notifications.eventReminders: true,
      t.profile.editProfile.notifications.marketing: false,
    };
    _notificationSubtitles = {
      t.profile.editProfile.notifications.newEvents: t.profile.editProfile.notificationSubtitles.newEvents,
      t.profile.editProfile.notifications.eventReminders: t.profile.editProfile.notificationSubtitles.eventReminders,
      t.profile.editProfile.notifications.marketing: t.profile.editProfile.notificationSubtitles.marketing,
    };
    _dataFuture = const UserRepository().getCurrentUser();
  }

  void _initFromData(UserData user) {
    if (_initialized) return;
    _initialized = true;
    final userDanceLabels = user.danceTags.map((tag) => tag.label).toSet();
    _dancePrefs = {for (final name in _kDanceStyleNames) name: userDanceLabels.contains(name)};
    _level = user.experienceLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          BackButtonHeader(
            title: t.profile.editProfile.title,
            onBack: () => context.pop(),
            trailing: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<UserData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final user = snapshot.data!;
                _initFromData(user);
                return StatefulBuilder(
                  builder: (context, setInnerState) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 140,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePhotoSection(
                            avatarUrl: user.avatarUrl ?? '',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                            child: SectionLabel(title: t.profile.editProfile.sections.personalInfo),
                          ),
                          PersonalInfoSection(
                            initialName: user.name,
                            initialEmail: user.email,
                            initialPhone: user.phone ?? '',
                            initialCity: user.city ?? '',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                            child: SectionLabel(title: t.profile.editProfile.sections.aboutMe),
                          ),
                          BioSection(
                            initialBio: user.bio ?? '',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                            child: SectionLabel(title: t.profile.editProfile.sections.favoriteDances),
                          ),
                          DancePreferencesSection(
                            preferences: _dancePrefs,
                            onChanged: (prefs) => setState(() => _dancePrefs
                              ..clear()
                              ..addAll(prefs)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                            child: SectionLabel(title: t.profile.editProfile.sections.level),
                          ),
                          ExperienceLevelSection(
                            levels: _kExperienceLevelNames,
                            selectedLevel: _level,
                            onChanged: (level) => setState(() => _level = level),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                            child: SectionLabel(title: t.profile.editProfile.sections.socialNetworks),
                          ),
                          const SocialLinksSection(),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                            child: SectionLabel(title: t.profile.editProfile.sections.notifications),
                          ),
                          NotificationsSection(
                            notifications: _notifications,
                            subtitles: _notificationSubtitles,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: SaveButtonSection(onSave: () => context.pop()),
    );
  }
}
