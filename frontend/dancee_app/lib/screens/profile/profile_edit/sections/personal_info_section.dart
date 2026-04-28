import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PersonalInfoSection extends StatelessWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialCity;

  const PersonalInfoSection({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    this.initialPhone = '',
    this.initialCity = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          _PersonalInfoField(
            label: t.common.form.fullName,
            initialValue: initialName,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PersonalInfoField(
            label: t.common.form.email,
            initialValue: initialEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PersonalInfoField(
            label: t.common.form.phone,
            initialValue: initialPhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PersonalInfoField(
            label: t.common.form.city,
            initialValue: initialCity,
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoField extends StatelessWidget {
  final String label;
  final String initialValue;
  final TextInputType keyboardType;

  const _PersonalInfoField({
    required this.label,
    required this.initialValue,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: appText,
              fontWeight: AppTypography.fontWeightMedium,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
