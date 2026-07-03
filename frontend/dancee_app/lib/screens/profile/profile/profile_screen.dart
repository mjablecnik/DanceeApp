import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../logic/cubits/editor_mode_cubit.dart';
import '../../../logic/cubits/profile_cubit.dart';
import '../../../logic/cubits/settings_cubit.dart';
import '../../../logic/states/auth_state.dart';
import '../../../logic/states/editor_mode_state.dart';
import '../../../logic/states/profile_state.dart';
import '../../../logic/states/settings_state.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/labels/section_label.dart';
// import 'components/premium_banner.dart';
import 'sections/account_section.dart';
import 'sections/app_info_section.dart';
import 'sections/logout_section.dart';
import 'sections/profile_card_section.dart';
import 'sections/settings_section.dart';
import 'sections/support_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _authError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileCubit>().loadProfile();
        // If profile fails because Directus tokens aren't ready yet,
        // auto-retry when they become available.
        context.read<AuthCubit>().directusLinkedNotifier.addListener(_onDirectusLinked);
      }
    });
  }

  void _onDirectusLinked() {
    if (!mounted) return;
    final profileState = context.read<ProfileCubit>().state;
    // Only reload if current state is error or initial (not already loaded)
    profileState.maybeMap(
      error: (_) => context.read<ProfileCubit>().loadProfile(),
      initial: (_) => context.read<ProfileCubit>().loadProfile(),
      orElse: () {},
    );
  }

  @override
  void dispose() {
    // Safe to call even if listener was never added
    try {
      context.read<AuthCubit>().directusLinkedNotifier.removeListener(_onDirectusLinked);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appSurface,
        title: Text(
          t.profile.danger.logout,
          style: const TextStyle(color: appText),
        ),
        content: Text(
          t.profile.danger.logoutConfirmBody,
          style: const TextStyle(color: appMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.common.cancel, style: const TextStyle(color: appMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.profile.danger.logout, style: const TextStyle(color: appError)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _authError = null);
      context.read<AuthCubit>().signOut();
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appSurface,
        title: Text(
          t.auth.deleteAccount.confirmTitle,
          style: const TextStyle(color: appText),
        ),
        content: Text(
          t.auth.deleteAccount.confirmBody,
          style: const TextStyle(color: appMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.common.cancel, style: const TextStyle(color: appMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.profile.danger.deleteAccount,
              style: const TextStyle(color: appError),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authCubit = context.read<AuthCubit>();
    final isEmailProvider = authCubit.isEmailProvider;
    final currentEmail = authCubit.currentEmail ?? '';

    String? email;
    String? password;

    if (isEmailProvider) {
      final credentials = await showDialog<(String, String)?>(
        context: context,
        builder: (ctx) => _ReauthDialog(email: currentEmail),
      );
      if (credentials == null || !mounted) return;
      email = credentials.$1;
      password = credentials.$2;
    }

    if (mounted) {
      setState(() => _authError = null);
      context.read<AuthCubit>().deleteAccount(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, _) {
        return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr.maybeMap(
        error: (_) => true,
        unauthenticated: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.mapOrNull(
          error: (s) => setState(() => _authError = s.message),
          unauthenticated: (_) {
            if (context.mounted) const LoginRoute().go(context);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);

        return ColoredBox(
          color: appBg,
          child: Stack(
            children: [
              Column(
                children: [
                  BackButtonHeader(
                    title: t.nav.profile,
                    onBack: context.canPop() ? () => context.pop() : null,
                    trailing: GestureDetector(
                      onTap: () => const ProfileEditRoute().push(context),
                      child: Container(
                        width: AppSizes.iconButtonMd,
                        height: AppSizes.iconButtonMd,
                        decoration: BoxDecoration(
                          color: appSurface,
                          borderRadius: BorderRadius.circular(AppRadius.round),
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.pen, size: AppIconSizes.xs, color: appText),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.xxl,
                        bottom: AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<ProfileCubit, ProfileState>(
                            builder: (context, profileState) {
                              return profileState.map(
                                initial: (_) => const SizedBox.shrink(),
                                loading: (_) => Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.lg),
                                      decoration: BoxDecoration(
                                        color: appSurface,
                                        border: Border.all(color: appBorder),
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                      ),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                          child: CircularProgressIndicator(color: appPrimary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                  ],
                                ),
                                loaded: (s) => Column(
                                  children: [
                                    ProfileCardSection(
                                      name: s.profile.fullName,
                                      email: s.profile.email,
                                      avatarUrl: s.profile.avatarUrl ?? '',
                                      danceTags: s.profile.danceTags
                                          .map((tag) => (label: tag, color: appPrimary))
                                          .toList(),
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                  ],
                                ),
                                updating: (s) => Column(
                                  children: [
                                    ProfileCardSection(
                                      name: s.profile.fullName,
                                      email: s.profile.email,
                                      avatarUrl: s.profile.avatarUrl ?? '',
                                      danceTags: s.profile.danceTags
                                          .map((tag) => (label: tag, color: appPrimary))
                                          .toList(),
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                  ],
                                ),
                                uploadingAvatar: (s) => Column(
                                  children: [
                                    ProfileCardSection(
                                      name: s.profile.fullName,
                                      email: s.profile.email,
                                      avatarUrl: s.profile.avatarUrl ?? '',
                                      danceTags: s.profile.danceTags
                                          .map((tag) => (label: tag, color: appPrimary))
                                          .toList(),
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                  ],
                                ),
                                error: (_) => Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.lg),
                                      decoration: BoxDecoration(
                                        color: appError.withValues(alpha: AppOpacity.faint),
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                        border: Border.all(color: appError.withValues(alpha: AppOpacity.low)),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            t.profile.error,
                                            style: const TextStyle(color: appError),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          TextButton(
                                            onPressed: () => context.read<ProfileCubit>().loadProfile(),
                                            child: Text(
                                              t.common.retry,
                                              style: const TextStyle(color: appPrimary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                  ],
                                ),
                              );
                            },
                          ),
                          SectionLabel(title: t.profile.sections.account),
                          const SizedBox(height: AppSpacing.md),
                          AccountSection(
                            onEditProfile: () => const ProfileEditRoute().push(context),
                            onChangePassword: () => const ChangePasswordRoute().push(context),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          BlocBuilder<EditorModeCubit, EditorModeState>(
                            builder: (context, editorState) {
                              if (!editorState.isEditor) return const SizedBox.shrink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionLabel(title: t.profile.sections.editorMode),
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appSurface,
                                      border: Border.all(color: appBorder),
                                      borderRadius: BorderRadius.circular(AppRadius.lg),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.editor.modeToggle,
                                                style: const TextStyle(
                                                  color: appText,
                                                  fontSize: AppTypography.fontSizeMd,
                                                  fontWeight: AppTypography.fontWeightMedium,
                                                ),
                                              ),
                                              const SizedBox(height: AppSpacing.xs),
                                              Text(
                                                t.editor.modeToggleSubtitle,
                                                style: const TextStyle(
                                                  color: appMuted,
                                                  fontSize: AppTypography.fontSizeSm,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: editorState.isEditorMode,
                                          onChanged: (_) =>
                                              context.read<EditorModeCubit>().toggleMode(),
                                          activeColor: appPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),
                                ],
                              );
                            },
                          ),
                          SectionLabel(title: t.profile.sections.settings),
                          const SizedBox(height: AppSpacing.md),
                          const SettingsSection(),
                          const SizedBox(height: AppSpacing.xxl),
                          // PremiumBanner(
                          //   onTap: () => const PremiumRoute().push(context),
                          // ),
                          // const SizedBox(height: AppSpacing.xxl),
                          SectionLabel(title: t.profile.sections.support),
                          const SizedBox(height: AppSpacing.md),
                          SupportSection(
                            onContactAuthor: () => const AuthorContactRoute().push(context),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          SectionLabel(title: t.profile.sections.appInfo),
                          const SizedBox(height: AppSpacing.md),
                          const AppInfoSection(),
                          const SizedBox(height: AppSpacing.xxl),
                          SectionLabel(title: t.profile.sections.dangerZone),
                          const SizedBox(height: AppSpacing.md),
                          if (_authError != null) ...[
                            _ErrorBanner(message: _authError!),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          LogoutSection(
                            onLogout: isLoading ? () {} : _handleLogout,
                            onDeleteAccount: isLoading ? () {} : _handleDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                const Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: appOverlay,
                      child: Center(
                        child: CircularProgressIndicator(color: appPrimary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appError.withValues(alpha: AppOpacity.faint),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appError.withValues(alpha: AppOpacity.low)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: appError, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: appError, fontSize: AppTypography.fontSizeMd),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReauthDialog extends StatefulWidget {
  final String email;

  const _ReauthDialog({required this.email});

  @override
  State<_ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<_ReauthDialog> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: appSurface,
      title: Text(
        t.auth.deleteAccount.confirmTitle,
        style: const TextStyle(color: appText),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.auth.deleteAccount.reauthPrompt,
            style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: const TextStyle(color: appText),
            decoration: InputDecoration(
              labelText: t.common.form.password,
              labelStyle: const TextStyle(color: appMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: appBorder),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: appPrimary),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: appMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(t.common.cancel, style: const TextStyle(color: appMuted)),
        ),
        TextButton(
          onPressed: () {
            if (_passwordController.text.isNotEmpty) {
              Navigator.pop(context, (widget.email, _passwordController.text));
            }
          },
          child: Text(
            t.profile.danger.deleteAccount,
            style: const TextStyle(color: appError),
          ),
        ),
      ],
    );
  }
}
