import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/back_button_header.dart';

/// Placeholder for the Legal Page screen.
/// Full implementation is in Task 11.
class LegalPageScreen extends StatelessWidget {
  final String slug;
  final String title;

  const LegalPageScreen({
    super.key,
    required this.slug,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appBg,
      child: Column(
        children: [
          BackButtonHeader(
            title: title,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                t.profile.legalPage.loading,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
