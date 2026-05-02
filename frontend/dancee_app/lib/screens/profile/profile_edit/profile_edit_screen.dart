import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/user_profile.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/profile_cubit.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/course_cubit.dart';
import '../../../logic/states/profile_state.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/labels/section_label.dart';
import 'sections/bio_section.dart';
import 'sections/dance_preferences_section.dart';
import 'sections/experience_level_section.dart';
import 'sections/notifications_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/profile_photo_section.dart';
import 'sections/save_button_section.dart';

const _kDanceStyleNames = [
  'Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Reggaeton',
  'Tango', 'Swing', 'Ballroom', 'Afro', 'Forró',
];

/// Maps Directus experience_level values to translation keys.
const _kExperienceLevelKeys = ['beginner', 'slightlyAdvanced', 'advanced', 'expert'];

String _experienceLevelLabel(String key) {
  final levels = t.profile.editProfile.experienceLevels;
  switch (key) {
    case 'beginner':
      return levels.beginner;
    case 'slightlyAdvanced':
      return levels.slightlyAdvanced;
    case 'advanced':
      return levels.advanced;
    case 'expert':
      return levels.expert;
    default:
      return key;
  }
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCity;
  final _bioController = TextEditingController();

  late Map<String, bool> _dancePrefs;
  late String _level;
  late Map<String, bool> _notifications;
  late Map<String, String> _notificationSubtitles;
  late Map<String, String> _notificationLabels;

  bool _initialized = false;
  bool _isSaving = false;

  // Stable keys for notification preferences (synced to Directus)
  static const _notifKeyNewEvents = 'new_events';
  static const _notifKeyReminders = 'event_reminders';
  static const _notifKeyMarketing = 'marketing';

  @override
  void initState() {
    super.initState();
    _dancePrefs = {for (final name in _kDanceStyleNames) name: false};
    _level = _kExperienceLevelKeys.first;
    _notifications = {
      _notifKeyNewEvents: true,
      _notifKeyReminders: true,
      _notifKeyMarketing: false,
    };
    _notificationLabels = {
      _notifKeyNewEvents: t.profile.editProfile.notifications.newEvents,
      _notifKeyReminders: t.profile.editProfile.notifications.eventReminders,
      _notifKeyMarketing: t.profile.editProfile.notifications.marketing,
    };
    _notificationSubtitles = {
      _notifKeyNewEvents: t.profile.editProfile.notificationSubtitles.newEvents,
      _notifKeyReminders: t.profile.editProfile.notificationSubtitles.eventReminders,
      _notifKeyMarketing: t.profile.editProfile.notificationSubtitles.marketing,
    };

    // If profile already loaded, initialize controllers immediately
    final state = context.read<ProfileCubit>().state;
    state.maybeMap(
      loaded: (s) => _initFromProfile(s.profile),
      updating: (s) => _initFromProfile(s.profile),
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _selectedCity = profile.city;
    _bioController.text = profile.bio ?? '';
    _dancePrefs = {
      for (final name in _kDanceStyleNames) name: profile.danceTags.contains(name),
    };
    _level = _kExperienceLevelKeys.contains(profile.experienceLevel)
        ? profile.experienceLevel
        : _kExperienceLevelKeys.first;
    _notifications = {
      _notifKeyNewEvents: profile.notificationPreferences[_notifKeyNewEvents] ?? true,
      _notifKeyReminders: profile.notificationPreferences[_notifKeyReminders] ?? true,
      _notifKeyMarketing: profile.notificationPreferences[_notifKeyMarketing] ?? false,
    };
  }

  List<String> _deriveAvailableRegions() {
    final regions = <String>{};
    final eventState = context.read<EventCubit>().state;
    eventState.maybeMap(
      loaded: (s) {
        for (final event in s.allEvents) {
          final venue = event.venue;
          if (venue == null) continue;
          if (kCzCountryValues.contains(venue.country)) {
            if (venue.region.isNotEmpty) regions.add(venue.region);
          }
        }
      },
      orElse: () {},
    );
    final courseState = context.read<CourseCubit>().state;
    courseState.maybeMap(
      loaded: (s) {
        for (final course in s.allCourses) {
          final venue = course.venue;
          if (venue == null) continue;
          if (kCzCountryValues.contains(venue.country)) {
            if (venue.region.isNotEmpty) regions.add(venue.region);
          }
        }
      },
      orElse: () {},
    );
    return regions.toList()..sort();
  }

  Future<void> _save() async {
    final cubit = context.read<ProfileCubit>();
    final name = _nameController.text.trim();
    final spaceIdx = name.indexOf(' ');
    final firstName = spaceIdx >= 0 ? name.substring(0, spaceIdx) : name;
    final lastName = spaceIdx >= 0 ? name.substring(spaceIdx + 1) : '';
    final selectedTags = _dancePrefs.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    setState(() => _isSaving = true);
    try {
      await cubit.updateProfile({
        'first_name': firstName,
        'last_name': lastName,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _selectedCity ?? '',
        'bio': _bioController.text.trim(),
        'dance_tags': selectedTags,
        'experience_level': _level,
        'notification_preferences': _notifications,
      });
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.profile.editProfile.updateError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (_, state) => state.maybeMap(
        loaded: (_) => true,
        updating: (_) => true,
        uploadingAvatar: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.maybeMap(
          loaded: (s) => _initFromProfile(s.profile),
          updating: (s) => _initFromProfile(s.profile),
          uploadingAvatar: (s) => _initFromProfile(s.profile),
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: appBg,
        body: Column(
          children: [
            BackButtonHeader(
              title: t.profile.editProfile.title,
              onBack: () => context.pop(),
              trailing: GestureDetector(
                onTap: _isSaving ? null : _save,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isSaving ? appMuted : appPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return state.map(
                    initial: (_) => const Center(child: CircularProgressIndicator()),
                    loading: (_) => const Center(child: CircularProgressIndicator()),
                    loaded: (s) {
                      _initFromProfile(s.profile);
                      return _buildForm();
                    },
                    updating: (s) {
                      _initFromProfile(s.profile);
                      return _buildForm();
                    },
                    uploadingAvatar: (s) {
                      _initFromProfile(s.profile);
                      return _buildForm();
                    },
                    error: (s) => Center(
                      child: Text(s.message, style: const TextStyle(color: appMuted)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomSheet: SaveButtonSection(
          onSave: _isSaving ? null : _save,
          isLoading: _isSaving,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePhotoSection(
                avatarUrl: context.read<ProfileCubit>().state.maybeMap(
                      loaded: (s) => s.profile.avatarUrl ?? '',
                      updating: (s) => s.profile.avatarUrl ?? '',
                      uploadingAvatar: (s) => s.profile.avatarUrl ?? '',
                      orElse: () => '',
                    ),
                name: _nameController.text,
                isUploading: context.read<ProfileCubit>().state.maybeMap(
                      uploadingAvatar: (_) => true,
                      orElse: () => false,
                    ),
              ),
              PersonalInfoSection(
                nameController: _nameController,
                emailController: _emailController,
                phoneController: _phoneController,
                selectedCity: _selectedCity,
                availableCities: _deriveAvailableRegions(),
                onCityChanged: (city) => setState(() => _selectedCity = city),
              ),
              BioSection(
                bioController: _bioController,
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
                levels: _kExperienceLevelKeys,
                selectedLevel: _level,
                onChanged: (level) => setState(() => _level = level),
                labelBuilder: _experienceLevelLabel,
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                child: SectionLabel(title: t.profile.editProfile.sections.notifications),
              ),
              NotificationsSection(
                notifications: {
                  for (final entry in _notifications.entries)
                    _notificationLabels[entry.key] ?? entry.key: entry.value,
                },
                subtitles: {
                  for (final entry in _notificationLabels.entries)
                    entry.value: _notificationSubtitles[entry.key] ?? '',
                },
                onToggle: (label, value) {
                  // Find the stable key for this label
                  final stableKey = _notificationLabels.entries
                      .firstWhere((e) => e.value == label, orElse: () => MapEntry(label, label))
                      .key;
                  setState(() => _notifications[stableKey] = value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
