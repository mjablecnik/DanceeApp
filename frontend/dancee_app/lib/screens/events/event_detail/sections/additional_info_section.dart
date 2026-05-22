import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class AdditionalInfoSection extends StatelessWidget {
  final String priceRange;
  final String dresscode;
  final List<MapEntry<String, String>> extraEntries;
  final VoidCallback? onBuyTickets;
  final VoidCallback? onSource;

  const AdditionalInfoSection({
    super.key,
    required this.priceRange,
    required this.dresscode,
    this.extraEntries = const [],
    this.onBuyTickets,
    this.onSource,
  });

  static bool _isUrlValue(String value) =>
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('www.');

  static Future<void> _launchUrl(String url) async {
    var uri = url;
    if (uri.startsWith('www.')) uri = 'https://$uri';
    final parsed = Uri.tryParse(uri);
    if (parsed != null) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPrice = priceRange.isNotEmpty;
    final hasDresscode = dresscode.isNotEmpty;
    final hasExtras = extraEntries.isNotEmpty;
    final hasAnyInfo = hasPrice || hasDresscode || hasExtras;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.detail.additionalInfo,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              if (hasPrice)
                InfoRow(label: t.events.detail.admission, value: priceRange),
              if (hasPrice && hasDresscode)
                const SizedBox(height: AppSpacing.md),
              if (hasDresscode)
                InfoRow(label: t.events.detail.dresscode, value: dresscode),
              for (var i = 0; i < extraEntries.length; i++) ...[
                if (hasPrice || hasDresscode || i > 0)
                  const SizedBox(height: AppSpacing.md),
                InfoRow(
                  label: extraEntries[i].key,
                  value: extraEntries[i].value,
                  onValueTap: _isUrlValue(extraEntries[i].value)
                      ? () => _launchUrl(extraEntries[i].value)
                      : null,
                ),
              ],
              if (hasAnyInfo && (onBuyTickets != null || onSource != null))
                const SizedBox(height: AppSpacing.lg),
              if (onBuyTickets != null) ...[
                BuyTicketsButton(onTap: onBuyTickets),
                if (onSource != null) const SizedBox(height: AppSpacing.sm),
              ],
              if (onSource != null)
                SourceButton(onTap: onSource),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onValueTap;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onValueTap,
  });

  bool get _isUrl =>
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('www.');

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _isUrl ? appPrimary : appMuted,
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ),
        if (_isUrl)
          const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 12, color: appPrimary)
        else
          Text(
            value,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
      ],
    );

    if (_isUrl && onValueTap != null) {
      return GestureDetector(onTap: onValueTap, child: content);
    }
    return content;
  }
}

class BuyTicketsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BuyTicketsButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: appPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.ticket, size: 14, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(
              t.events.detail.buyTickets,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SourceButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SourceButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 14, color: appText),
            const SizedBox(width: AppSpacing.sm),
            Text(
              t.events.detail.originalSource,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
