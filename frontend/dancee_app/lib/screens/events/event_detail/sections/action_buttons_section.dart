import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/outline_action_button.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onMap;

  const ActionButtonsSection({
    super.key,
    this.onShare,
    this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: OutlineActionButton(
          icon: FontAwesomeIcons.shareNodes,
          label: t.common.share,
          onTap: onShare,
        )),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: OutlineActionButton(
          icon: FontAwesomeIcons.mapLocationDot,
          label: t.common.map,
          onTap: onMap,
        )),
      ],
    );
  }
}
