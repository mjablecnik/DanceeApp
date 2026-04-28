import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_routes.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/password_strength_bar.dart';
import '../components/password_requirement_row.dart';

class PasswordFormSection extends StatefulWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const PasswordFormSection({
    super.key,
    this.onSave,
    this.onCancel,
  });

  @override
  State<PasswordFormSection> createState() => _PasswordFormSectionState();
}

class _PasswordFormSectionState extends State<PasswordFormSection> {
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _passwordStrength = 0;
  bool _passwordMismatch = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluateStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'\d'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    setState(() {
      _passwordStrength = password.isEmpty ? 0 : strength;
    });
  }

  void _checkMatch(String confirm) {
    setState(() {
      _passwordMismatch =
          confirm.isNotEmpty && confirm != _newPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordField(
          label: t.profile.changePassword.currentPassword,
          placeholder: t.profile.changePassword.currentPasswordHint,
          controller: _currentPasswordController,
          visible: _currentPasswordVisible,
          onToggle: () =>
              setState(() => _currentPasswordVisible = !_currentPasswordVisible),
        ),
        const SizedBox(height: AppSpacing.xl),
        NewPasswordField(
          controller: _newPasswordController,
          confirmController: _confirmPasswordController,
          visible: _newPasswordVisible,
          passwordStrength: _passwordStrength,
          onToggle: () =>
              setState(() => _newPasswordVisible = !_newPasswordVisible),
          onEvaluateStrength: _evaluateStrength,
          onCheckMatch: _checkMatch,
        ),
        const SizedBox(height: AppSpacing.xl),
        ConfirmPasswordField(
          controller: _confirmPasswordController,
          visible: _confirmPasswordVisible,
          passwordMismatch: _passwordMismatch,
          onToggle: () => setState(
              () => _confirmPasswordVisible = !_confirmPasswordVisible),
          onCheckMatch: _checkMatch,
        ),
        const SizedBox(height: 28),
        PasswordActionButtons(
          onSave: widget.onSave,
          onCancel: widget.onCancel,
        ),
        const SizedBox(height: AppSpacing.sm),
        const PasswordRequirementsSection(),
        const SizedBox(height: AppSpacing.xxl),
        const ForgotPasswordLink(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class PasswordField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;

  const PasswordField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !visible,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: FaIcon(
                    visible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                    size: 16,
                    color: appMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NewPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController confirmController;
  final bool visible;
  final int passwordStrength;
  final VoidCallback onToggle;
  final void Function(String) onEvaluateStrength;
  final void Function(String) onCheckMatch;

  const NewPasswordField({
    super.key,
    required this.controller,
    required this.confirmController,
    required this.visible,
    required this.passwordStrength,
    required this.onToggle,
    required this.onEvaluateStrength,
    required this.onCheckMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.profile.changePassword.newPassword,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !visible,
                  onChanged: (val) {
                    onEvaluateStrength(val);
                    if (confirmController.text.isNotEmpty) {
                      onCheckMatch(confirmController.text);
                    }
                  },
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  decoration: InputDecoration(
                    hintText: t.profile.changePassword.newPasswordHint,
                    hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: FaIcon(
                    visible
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                    color: appMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (passwordStrength > 0) ...[
          const SizedBox(height: 10),
          PasswordStrengthBar(strength: passwordStrength),
        ],
      ],
    );
  }
}

class ConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;
  final bool passwordMismatch;
  final VoidCallback onToggle;
  final void Function(String) onCheckMatch;

  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.visible,
    required this.passwordMismatch,
    required this.onToggle,
    required this.onCheckMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.profile.changePassword.confirmPassword,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !visible,
                  onChanged: onCheckMatch,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  decoration: InputDecoration(
                    hintText: t.profile.changePassword.confirmPasswordHint,
                    hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: FaIcon(
                    visible
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                    color: appMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (passwordMismatch) ...[
          const SizedBox(height: 6),
          Text(
            t.auth.register.passwordsMismatch,
            style: const TextStyle(
              color: appError,
              fontSize: AppTypography.fontSizeSm,
            ),
          ),
        ],
      ],
    );
  }
}

class PasswordActionButtons extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const PasswordActionButtons({
    super.key,
    this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSave ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              elevation: 4,
              shadowColor: appPrimary.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  t.profile.changePassword.save,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel ?? () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: appText,
              side: const BorderSide(color: appBorder),
              backgroundColor: appSurface,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
            child: Text(
              t.common.cancel,
              style: const TextStyle(
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordRequirementsSection extends StatelessWidget {
  const PasswordRequirementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: appBorder, height: 48),
        Text(
          t.profile.changePassword.requirements,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightSemiBold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PasswordRequirementRow(text: t.profile.changePassword.req8chars),
        const SizedBox(height: 10),
        PasswordRequirementRow(text: t.profile.changePassword.reqUppercase),
        const SizedBox(height: 10),
        PasswordRequirementRow(text: t.profile.changePassword.reqLowercase),
        const SizedBox(height: 10),
        PasswordRequirementRow(text: t.profile.changePassword.reqNumber),
        const SizedBox(height: 10),
        PasswordRequirementRow(text: t.profile.changePassword.reqSpecial),
      ],
    );
  }
}

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => const ForgotPasswordRoute().push(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.circleQuestion, size: 14, color: appPrimary),
            const SizedBox(width: 6),
            Text(
              t.profile.changePassword.forgotPassword,
              style: const TextStyle(
                color: appPrimary,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
