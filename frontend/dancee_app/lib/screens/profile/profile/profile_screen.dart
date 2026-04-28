import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../logic/states/auth_state.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/labels/section_label.dart';
import 'sections/logout_section.dart';
import 'sections/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _authError;

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
                    title: t.profile.title,
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.xxl,
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(title: t.profile.sections.settings),
                          const SizedBox(height: AppSpacing.md),
                          const SettingsSection(),
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
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: const Color(0x80000000),
                      child: const Center(
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
        color: appError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appError.withValues(alpha: 0.3)),
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
