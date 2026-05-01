import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController cityController;

  const PersonalInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.cityController,
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
            controller: nameController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PersonalInfoField(
            label: t.common.form.email,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PersonalInfoField(
            label: t.common.form.phone,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PersonalInfoField(
            label: t.common.form.city,
            controller: cityController,
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? placeholder;

  const _PersonalInfoField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.placeholder,
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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSizeMd,
            ),
            decoration: InputDecoration(
              hintText: placeholder ?? label,
              hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
