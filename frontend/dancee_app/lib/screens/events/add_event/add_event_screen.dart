import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../logic/cubits/add_event_cubit.dart';
import '../../../logic/states/add_event_state.dart';
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
    return BlocProvider(
      create: (_) => AddEventCubit(eventRepository: sl<EventRepository>()),
      child: const _AddEventView(),
    );
  }
}

class _AddEventView extends StatefulWidget {
  const _AddEventView();

  @override
  State<_AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<_AddEventView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadejte název akce')),
      );
      return;
    }

    final fields = <String, dynamic>{
      if (title.isNotEmpty) 'title': title,
      if (description.isNotEmpty) 'description': description,
    };

    context.read<AddEventCubit>().submitEvent(fields);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddEventCubit, AddEventState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akce byla odeslána ke schválení'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      child: BlocBuilder<AddEventCubit, AddEventState>(
        builder: (context, state) {
          final isSubmitting = state.maybeWhen(submitting: () => true, orElse: () => false);
          return Scaffold(
            backgroundColor: appBg,
            body: Column(
              children: [
                AddEventHeaderSection(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      top: AppSpacing.xxl,
                      bottom: 120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddEventBasicInfoSection(
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const AddEventDateTimeSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        const AddEventLocationSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        const AddEventOrganizerSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        const AddEventStylesSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        const AddEventAdditionalInfoSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        const AddEventProgramSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        AddEventSubmitSection(
                          onSubmit: _submit,
                          isSubmitting: isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const AppBottomNavBar(currentTab: NavTab.events),
          );
        },
      ),
    );
  }
}
