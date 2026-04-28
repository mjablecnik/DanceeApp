import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/theme.dart';
import '../../../../../i18n/strings.g.dart';

class DeviceInfoRow {
  final String label;
  final String value;

  const DeviceInfoRow({required this.label, required this.value});
}

class DeviceInfoCard extends StatelessWidget {
  final List<DeviceInfoRow> rows;

  const DeviceInfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.mobileScreen, color: appMuted, size: 14),
              const SizedBox(width: AppSpacing.sm),
              Text(
                t.contact.deviceInfo,
                style: const TextStyle(
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                  color: appText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: appPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  t.contact.autoAttached,
                  style: const TextStyle(fontSize: AppTypography.fontSizeSm, color: appPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: const TextStyle(fontSize: AppTypography.fontSizeSm, color: appMuted),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(fontSize: AppTypography.fontSizeSm, color: appMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
