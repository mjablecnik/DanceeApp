import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class AuthFooterSection extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const AuthFooterSection({
    super.key,
    required this.text,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        TextButton(
          onPressed: onLinkTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            linkText,
            style: const TextStyle(
              color: appPrimary,
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
        ),
      ],
    );
  }
}
