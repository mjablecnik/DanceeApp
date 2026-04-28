import 'package:flutter/foundation.dart';
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
import '../../../../shared/elements/forms/app_checkbox.dart';
import '../../../../shared/elements/forms/app_input_field.dart';
import '../../../../shared/elements/forms/app_password_field.dart';
import '../../../../shared/elements/buttons/social_button.dart';
import '../../../../shared/utils/auth_translations.dart';
import '../../../../shared/utils/form_validators.dart';

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  bool _stayLoggedIn = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) _validatePassword();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() => _emailError =
        resolveValidationKey(FormValidators.email(_emailController.text)));
  }

  void _validatePassword() {
    setState(() => _passwordError =
        resolveValidationKey(FormValidators.notEmpty(_passwordController.text)));
  }

  bool _validateAll() {
    _validateEmail();
    _validatePassword();
    return _emailError == null && _passwordError == null;
  }

  void _onSubmit() {
    if (!_validateAll()) return;
    setState(() => _authError = null);
    context.read<AuthCubit>().signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr.maybeMap(
        error: (_) => true,
        authenticated: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.mapOrNull(
          error: (s) => setState(() => _authError = resolveAuthErrorKey(s.message)),
          authenticated: (_) => setState(() => _authError = null),
        );
      },
      buildWhen: (prev, curr) =>
          curr.maybeMap(loading: (_) => true, orElse: () => false) ||
          prev.maybeMap(loading: (_) => true, orElse: () => false),
      builder: (context, state) {
        final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);
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
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              label: t.common.form.password,
              controller: _passwordController,
              focusNode: _passwordFocus,
              errorText: _passwordError,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                AppCheckbox(
                  checked: _stayLoggedIn,
                  onChanged: (val) => setState(() => _stayLoggedIn = val),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  t.auth.login.stayLoggedIn,
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => const ForgotPasswordRoute().go(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.auth.login.forgotPassword,
                    style: const TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
                ),
              ],
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
              label: t.auth.login.submit,
              isLoading: isLoading,
              onTap: _onSubmit,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              children: [
                const Expanded(child: Divider(color: appBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    t.auth.orContinueWith,
                    style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                  ),
                ),
                const Expanded(child: Divider(color: appBorder)),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            SocialButton(
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
              label: t.auth.continueWithGoogle,
              onTap: isLoading ? () {} : () => context.read<AuthCubit>().signInWithGoogle(),
            ),
            if (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS) ...[
              const SizedBox(height: AppSpacing.md),
              SocialButton(
                icon: const FaIcon(FontAwesomeIcons.apple, color: appText, size: 20),
                label: t.auth.continueWithApple,
                onTap: isLoading ? () {} : () => context.read<AuthCubit>().signInWithApple(),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.auth.login.noAccount,
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  onPressed: () => const RegisterRoute().go(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.auth.login.register,
                    style: const TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: appBorder),
            const SizedBox(height: AppSpacing.lg),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeSm,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: t.auth.termsPrefix),
                  TextSpan(
                    text: t.auth.termsOfUse,
                    style: const TextStyle(color: appPrimary),
                  ),
                  TextSpan(text: t.auth.and),
                  TextSpan(
                    text: t.auth.privacyPolicy,
                    style: const TextStyle(color: appPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        );
      },
    );
  }
}

