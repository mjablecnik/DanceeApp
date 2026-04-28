import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import 'sections/saved_events_header_section.dart';
import 'sections/saved_events_list_section.dart';

class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: appBg,
      child: Column(
        children: [
          SavedEventsHeaderSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16, top: AppSpacing.xxl),
              child: SavedEventsListSection(),
            ),
          ),
        ],
      ),
    );
  }
}
