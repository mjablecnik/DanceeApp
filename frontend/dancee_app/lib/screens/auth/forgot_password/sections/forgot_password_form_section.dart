import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/app_routes.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/auth_cubit.dart';
import '../../../../logic/states/auth_state.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/forms/app_input_field.dart';
import '../../../../shared/utils/auth_translations.dart';
import '../../../../shared/utils/form_validators.dart';

class ForgotPasswordFormSection extends StatefulWidget {
  const ForgotPasswordFormSection({super.key});

  @override
  State<ForgotPasswordFormSection> createState() => _ForgotPasswordFormSectionState();
}

class _ForgotPasswordFormSectionState extends State<ForgotPasswordFormSection> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  String? _emailError;
  String? _authError;
  bool _emailSent = false;

  StreamSubscription<AuthOperation>? _operationSuccessSub;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _operationSuccessSub?.cancel();
    _operationSuccessSub = context
        .read<AuthCubit>()
        .operationSuccess
        .where((op) => op == AuthOperation.passwordReset)
        .listen((_) {
      if (mounted) {
        setState(() => _emailSent = true);
      }
    });
  }

  @override
  void dispose() {
    _operationSuccessSub?.cancel();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() => _emailError =
        resolveValidationKey(FormValidators.email(_emailController.text)));
  }

  void _onSubmit() {
    _validateEmail();
    if (_emailError != null) return;
    setState(() => _authError = null);
    context.read<AuthCubit>().sendPasswordReset(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth errors — sendPasswordReset emits AuthState.error on failure.
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr.maybeMap(error: (_) => true, orElse: () => false),
      listener: (context, state) {
        state.mapOrNull(
          error: (s) => setState(() => _authError = resolveAuthErrorKey(s.message)),
        );
      },
      // Use operationInProgress notifier for loading so that sendPasswordReset
      // does not emit AuthState.loading() into the global auth state.
      child: ListenableBuilder(
        listenable: context.read<AuthCubit>().operationInProgress,
        builder: (context, _) {
          final isLoading = context.read<AuthCubit>().operationInProgress.value;
          return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInputField(
              label: t.common.form.email,
              hintText: t.common.form.emailHint,
              keyboardType: TextInputType.emailAddress,
              icon: const FaIcon(FontAwesomeIcons.envelope, color: appMuted, size: 16),
              controller: _emailController,
              focusNode: _emailFocus,
              errorText: _emailError,
            ),
            if (_authError != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _authError!,
                style: const TextStyle(color: appError, fontSize: AppTypography.fontSizeSm),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(
              label: t.auth.forgotPassword.submit,
              isLoading: isLoading,
              onTap: _onSubmit,
            ),
            if (_emailSent) ...[
              const SizedBox(height: AppSpacing.xxl),
              Container(
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: appBorder),
                ),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: appPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: appPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.auth.forgotPassword.checkInbox,
                            style: const TextStyle(
                              color: appText,
                              fontSize: AppTypography.fontSizeMd,
                              fontWeight: AppTypography.fontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            t.auth.forgotPassword.checkInboxDetail,
                            style: const TextStyle(
                              color: appMuted,
                              fontSize: AppTypography.fontSizeSm,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.auth.forgotPassword.rememberPassword,
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
                TextButton(
                  onPressed: () => const LoginRoute().go(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.auth.forgotPassword.login,
                    style: const TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              children: [
                const Expanded(child: Divider(color: appBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    t.auth.forgotPassword.needHelp,
                    style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                  ),
                ),
                const Expanded(child: Divider(color: appBorder)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _HelpButton(
                    icon: const FaIcon(FontAwesomeIcons.headset, color: appPrimary, size: 16),
                    label: t.common.support,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _HelpButton(
                    icon: const FaIcon(FontAwesomeIcons.circleQuestion, color: appAccent, size: 16),
                    label: t.common.faq,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        );
        },
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _HelpButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
