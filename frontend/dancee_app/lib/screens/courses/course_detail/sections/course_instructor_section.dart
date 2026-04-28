import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/instructor_card.dart';

export '../components/instructor_card.dart' show InstructorStat;

class CourseInstructorSection extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String bio;
  final List<InstructorStat> stats;

  const CourseInstructorSection({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.bio,
    this.stats = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.courses.detail.aboutInstructor,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        InstructorCard(
          avatarUrl: avatarUrl,
          name: name,
          bio: bio,
          stats: stats,
        ),
      ],
    );
  }
}
