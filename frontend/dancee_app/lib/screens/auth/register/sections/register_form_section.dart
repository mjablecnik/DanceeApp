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
import '../components/password_strength_indicator.dart';

class RegisterFormSection extends StatefulWidget {
  const RegisterFormSection({super.key});

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _authError;

  bool _agreeTerms = false;
  bool _termsError = false;
  bool _newsletter = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _firstNameFocus.addListener(() {
      if (!_firstNameFocus.hasFocus) _validateFirstName();
    });
    _lastNameFocus.addListener(() {
      if (!_lastNameFocus.hasFocus) _validateLastName();
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) _validatePassword();
    });
    _confirmPasswordFocus.addListener(() {
      if (!_confirmPasswordFocus.hasFocus) _validateConfirmPassword();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength = FormValidators.passwordStrength(_passwordController.text);
    });
  }

  void _validateFirstName() {
    setState(() => _firstNameError =
        resolveValidationKey(FormValidators.notEmpty(_firstNameController.text)));
  }

  void _validateLastName() {
    setState(() => _lastNameError =
        resolveValidationKey(FormValidators.notEmpty(_lastNameController.text)));
  }

  void _validateEmail() {
    setState(() => _emailError =
        resolveValidationKey(FormValidators.email(_emailController.text)));
  }

  void _validatePassword() {
    setState(() => _passwordError =
        resolveValidationKey(FormValidators.password(_passwordController.text)));
  }

  void _validateConfirmPassword() {
    setState(() => _confirmPasswordError = resolveValidationKey(
      FormValidators.confirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      ),
    ));
  }

  bool _validateAll() {
    _validateFirstName();
    _validateLastName();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();
    setState(() => _termsError = !_agreeTerms);
    return _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _agreeTerms;
  }

  Future<void> _onSubmit() async {
    if (!_validateAll()) return;
    setState(() => _authError = null);
    final cubit = context.read<AuthCubit>();
    await cubit.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    if (!mounted) return;
    final state = cubit.state;
    // Only send email verification if register succeeded (authenticated state)
    if (state.maybeMap(authenticated: (_) => true, orElse: () => false)) {
      await cubit.sendEmailVerification();
    }
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
              label: t.common.form.firstName,
              hintText: t.common.form.firstNameHint,
              icon: const FaIcon(FontAwesomeIcons.user, color: appMuted, size: 16),
              controller: _firstNameController,
              focusNode: _firstNameFocus,
              errorText: _firstNameError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppInputField(
              label: t.common.form.lastName,
              hintText: t.common.form.lastNameHint,
              icon: const FaIcon(FontAwesomeIcons.user, color: appMuted, size: 16),
              controller: _lastNameController,
              focusNode: _lastNameFocus,
              errorText: _lastNameError,
            ),
            const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.sm),
            PasswordStrengthIndicator(
              strength: _passwordStrength,
              isEmpty: _passwordController.text.isEmpty,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              label: t.common.form.confirmPassword,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              errorText: _confirmPasswordError,
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () => setState(() {
                _agreeTerms = !_agreeTerms;
                if (_agreeTerms) _termsError = false;
              }),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCheckbox(
                    checked: _agreeTerms,
                    onChanged: (val) => setState(() {
                      _agreeTerms = val;
                      if (val) _termsError = false;
                    }),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: _termsError ? appError : appMuted,
                          fontSize: AppTypography.fontSizeMd,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: t.auth.agreeWith),
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => setState(() => _newsletter = !_newsletter),
              child: Row(
                children: [
                  AppCheckbox(
                    checked: _newsletter,
                    onChanged: (val) => setState(() => _newsletter = val),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t.auth.register.newsletter,
                      style: const TextStyle(
                        color: appMuted,
                        fontSize: AppTypography.fontSizeMd,
                      ),
                    ),
                  ),
                ],
              ),
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
              label: t.auth.register.submit,
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
                    t.auth.orRegisterWith,
                    style: const TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeMd,
                    ),
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
                  t.auth.register.hasAccount,
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  onPressed: () => const LoginRoute().go(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.auth.register.login,
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
          ],
        );
      },
    );
  }
}

