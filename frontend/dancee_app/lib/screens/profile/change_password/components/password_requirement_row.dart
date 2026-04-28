import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class PasswordRequirementRow extends StatelessWidget {
  final String text;

  const PasswordRequirementRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FaIcon(FontAwesomeIcons.circleCheck, size: 14, color: appMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
        ),
      ],
    );
  }
}
