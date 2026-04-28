import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../i18n/strings.g.dart';

class AuthHeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  /// When true, uses a smaller layout suited for the register screen.
  final bool compact;

  /// When true, shows the "Objevuj taneční svět" tagline below the app name.
  final bool showTagline;

  const AuthHeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = FontAwesomeIcons.music,
    this.compact = false,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    final double containerSize = compact ? 64 : 80;
    final double iconSize = compact ? 24 : 32;
    final double containerRadius = compact ? AppRadius.xl : AppRadius.round;
    final double appNameFontSize =
        compact ? AppTypography.fontSize5xl : AppTypography.fontSize6xl;
    final double titleFontSize =
        compact ? AppTypography.fontSize3xl : AppTypography.fontSize4xl;

    return Column(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(containerRadius),
            boxShadow: [AppShadows.primaryLg],
          ),
          child: Center(
            child: FaIcon(icon, color: Colors.white, size: iconSize),
          ),
        ),
        SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
        ShaderMask(
          shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
          child: Text(
            t.common.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: appNameFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (showTagline) ...[
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            t.auth.tagline,
            style: TextStyle(
              color: appMuted,
              fontSize: compact
                  ? AppTypography.fontSizeMd
                  : AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.xl : AppSpacing.xxxl),
        ] else
          SizedBox(height: compact ? AppSpacing.xl : AppSpacing.xxl),
        Text(
          title,
          style: TextStyle(
            color: appText,
            fontSize: titleFontSize,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appMuted,
              fontSize: compact ? AppTypography.fontSizeMd : null,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
