import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/utils/region_label.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? selectedCity;
  final List<String> availableCities;
  final ValueChanged<String?> onCityChanged;

  const PersonalInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedCity,
    required this.availableCities,
    required this.onCityChanged,
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
          _CityDropdown(
            label: t.events.location,
            selectedCity: selectedCity,
            availableCities: availableCities,
            onChanged: onCityChanged,
          ),
        ],
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final String label;
  final String? selectedCity;
  final List<String> availableCities;
  final ValueChanged<String?> onChanged;

  const _CityDropdown({
    required this.label,
    required this.selectedCity,
    required this.availableCities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = availableCities.where((c) => c != 'Other').toList();
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filtered.contains(selectedCity) ? selectedCity : null,
              hint: Text(
                label,
                style: TextStyle(color: appMuted.withValues(alpha: 0.6)),
              ),
              isExpanded: true,
              dropdownColor: appSurface,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 2,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: appMuted),
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeMd,
              ),
              items: filtered
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(regionLabel(city)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonalInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _PersonalInfoField({
    required this.label,
    required this.controller,
    required this.keyboardType,
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
              hintText: label,
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
