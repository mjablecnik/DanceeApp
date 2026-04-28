import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class NotificationsSection extends StatefulWidget {
  final Map<String, bool> notifications;
  final Map<String, String> subtitles;
  final void Function(String key, bool value)? onToggle;

  const NotificationsSection({
    super.key,
    required this.notifications,
    required this.subtitles,
    this.onToggle,
  });

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  late Map<String, bool> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = Map.from(widget.notifications);
  }

  void _toggle(String key, bool value) {
    setState(() => _notifications[key] = value);
    widget.onToggle?.call(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final keys = _notifications.keys.toList();
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: keys.asMap().entries.map((entry) {
            final i = entry.key;
            final key = entry.value;
            return Column(
              children: [
                if (i > 0) const Divider(height: 1, color: appBorder),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key,
                              style: const TextStyle(
                                color: appText,
                                fontWeight: AppTypography.fontWeightMedium,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitles[key]!,
                              style: const TextStyle(
                                color: appMuted,
                                fontSize: AppTypography.fontSizeSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notifications[key]!,
                        onChanged: (val) => _toggle(key, val),
                        activeColor: appPrimary,
                        inactiveTrackColor: appBorder,
                        inactiveThumbColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
