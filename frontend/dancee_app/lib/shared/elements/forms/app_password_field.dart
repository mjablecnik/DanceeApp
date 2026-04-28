import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';

class AppPasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final FocusNode? focusNode;

  const AppPasswordField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.errorText,
    this.focusNode,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: widget.errorText != null ? appError : appBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.lg),
              const FaIcon(FontAwesomeIcons.lock, color: appMuted, size: 16),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: !_showPassword,
                  onChanged: widget.onChanged,
                  style: const TextStyle(color: appText),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? t.common.form.passwordPlaceholder,
                    hintStyle: const TextStyle(color: appMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showPassword = !_showPassword),
                child: FaIcon(
                  _showPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                  color: appMuted,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: const TextStyle(
              color: appError,
              fontSize: AppTypography.fontSizeSm,
            ),
          ),
        ],
      ],
    );
  }
}
