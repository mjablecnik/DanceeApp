import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/cubits/event_detail_cubit.dart';
import '../../../logic/states/event_detail_state.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, required this.eventId});

  final int eventId;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  @override
  void initState() {
    super.initState();
    final locale = Localizations.localeOf(context).languageCode;
    context.read<EventDetailCubit>().loadEvent(widget.eventId, locale);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailCubit, EventDetailState>(
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
