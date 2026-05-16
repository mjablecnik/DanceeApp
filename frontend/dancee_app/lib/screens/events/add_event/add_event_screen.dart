import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'sections/add_event_header_section.dart';
import 'sections/add_event_basic_info_section.dart';
import 'sections/add_event_datetime_section.dart';
import 'sections/add_event_location_section.dart';
import 'sections/add_event_organizer_section.dart';
import 'sections/add_event_styles_section.dart';
import 'sections/add_event_additional_info_section.dart';
import 'sections/add_event_program_section.dart';
import 'sections/add_event_submit_section.dart';

class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          AddEventHeaderSection(onBack: () => context.pop()),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xxl,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddEventBasicInfoSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventDateTimeSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventLocationSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventOrganizerSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventStylesSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventAdditionalInfoSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventProgramSection(),
                  SizedBox(height: AppSpacing.xxl),
                  AddEventSubmitSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: NavTab.events),
    );
  }
}
