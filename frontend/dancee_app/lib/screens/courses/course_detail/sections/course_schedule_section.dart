import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/schedule_card.dart';

class ScheduleDetail {
  final String label;
  final String value;

  const ScheduleDetail({required this.label, required this.value});
}

class CourseScheduleSection extends StatelessWidget {
  final List<ScheduleDetail> details;
  final List<String> learningItems;

  const CourseScheduleSection({
    super.key,
    required this.details,
    this.learningItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.courses.detail.details,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
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
              for (int i = 0; i < details.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                ScheduleCard(label: details[i].label, value: details[i].value),
              ],
            ],
          ),
        ),
        if (learningItems.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text(
            t.courses.detail.whatYouLearn,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < learningItems.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: FaIcon(FontAwesomeIcons.check, size: 14, color: appSuccess),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    learningItems[i],
                    style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                  ),
                ),
              ],
            ),
            if (i < learningItems.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
    );
  }
}
