import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/cubits/course_detail_cubit.dart';
import '../../../logic/states/course_detail_state.dart';

class EditCourseScreen extends StatefulWidget {
  const EditCourseScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  @override
  void initState() {
    super.initState();
    final locale = Localizations.localeOf(context).languageCode;
    context.read<CourseDetailCubit>().loadCourse(widget.courseId, locale);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailCubit, CourseDetailState>(
      builder: (context, state) {
        return Scaffold(
          body: state.map(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            loaded: (_) => const Center(child: CircularProgressIndicator()),
            editing: (_) => const Center(child: CircularProgressIndicator()),
            submitting: (_) => const Center(child: CircularProgressIndicator()),
            success: (_) => const Center(child: CircularProgressIndicator()),
            error: (s) => Center(child: Text(s.message)),
          ),
        );
      },
    );
  }
}
