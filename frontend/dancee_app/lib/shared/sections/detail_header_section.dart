import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class DetailHeaderSection extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final List<Widget>? actions;

  const DetailHeaderSection({
    super.key,
    required this.title,
    required this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: actions!)
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.ellipsisVertical, size: 16, color: appText),
              ),
            ),
        ],
      ),
    );
  }
}
