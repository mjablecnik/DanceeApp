import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'sections/add_course_header_section.dart';
import 'sections/add_course_basic_info_section.dart';
import 'sections/add_course_schedule_section.dart';
import 'sections/add_course_pricing_section.dart';
import 'sections/add_course_submit_section.dart';

class AddCourseScreen extends StatelessWidget {
  const AddCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          AddCourseHeaderSection(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xxl,
                bottom: 120,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddCourseBasicInfoSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddCourseScheduleSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddCoursePricingSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddCourseSubmitSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: NavTab.courses),
    );
  }
}
