import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/event.dart';
import '../../../data/entities/event_info.dart';
import '../../../data/entities/event_part.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../logic/cubits/editor_mode_cubit.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/event_detail_cubit.dart';
import '../../../logic/cubits/favorites_cubit.dart';
import '../../../logic/states/editor_mode_state.dart';
import '../../../logic/states/event_detail_state.dart';
import '../../../shared/sections/description_section.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/url_launcher.dart';
import '../../../shared/sections/detail_header_section.dart';
import '../../../shared/sections/hero_image_section.dart';
import '../../../shared/sections/key_info_section.dart';
import 'sections/action_buttons_section.dart';
import 'sections/additional_info_section.dart';
import 'sections/event_program_section.dart';
import 'sections/event_title_section.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final cachedEvents = context.read<EventCubit>().state.maybeMap(
            loaded: (s) => s.allEvents,
            orElse: () => null,
          );
      final locale = Localizations.localeOf(context).languageCode;
      context.read<EventDetailCubit>().loadEvent(
            widget.eventId,
            locale,
            cachedEvents: cachedEvents,
          );
    }
  }

  List<KeyInfoItem> _buildKeyInfo(Event event) {
    final items = <KeyInfoItem>[];

    // Date/time
    final startDateStr = formatDate(event.startTime);
    final startDay = event.startTime.toIso8601String().substring(0, 10);
    final endDay = event.endTime?.toIso8601String().substring(0, 10);
    final isMultiDay = event.endTime != null && endDay != startDay;

    final dateTitle = isMultiDay
        ? '$startDateStr – ${formatDate(event.endTime!)}'
        : startDateStr;

    // Build time subtitle
    String timeSubtitle;
    final startTime = formatTime(event.startTime);
    final endTime = event.endTime != null ? formatTime(event.endTime!) : null;
    final sameTime = endTime != null && startTime == endTime;

    if (sameTime) {
      timeSubtitle = '';
    } else if (isMultiDay && endTime != null) {
      timeSubtitle = t.common.from(time: startTime);
    } else if (endTime != null) {
      timeSubtitle = '$startTime – $endTime';
    } else {
      timeSubtitle = t.common.from(time: startTime);
    }

    items.add(KeyInfoItem(
      icon: FontAwesomeIcons.calendar,
      title: dateTitle,
      subtitle: timeSubtitle,
    ));

    // Venue
    if (event.venue != null) {
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.locationDot,
        title: event.venue!.name,
        subtitle: event.venue!.fullAddress,
      ));
    }

    // Organizer
    if (event.organizer.isNotEmpty) {
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.user,
        title: event.organizer,
        subtitle: '',
      ));
    }

    // Additional info items (url type shown as key info — only registration-like links, not workshops)
    // Workshop-type entries (url with key containing price) are shown in AdditionalInfoSection below.

    return items;
  }

  List<ProgramDayData> _buildProgram(List<EventPart> parts) {
    if (parts.isEmpty) return [];

    // Group parts by date
    final Map<String, List<EventPart>> byDate = {};
    for (final part in parts) {
      final key = part.startTime != null
          ? formatDate(part.startTime!)
          : t.events.detail.program;
      byDate.putIfAbsent(key, () => []).add(part);
    }

    return byDate.entries.map((entry) {
      return ProgramDayData(
        day: entry.key,
        slots: entry.value.map((part) {
          final timeStr = part.startTime != null
              ? formatTime(part.startTime!)
              : '';
          final lectorExtras = part.lectors
              .map((l) => SlotExtra(t.events.detail.lector(name: l), appLavender))
              .toList();
          final djExtras = part.djs
              .map((dj) => SlotExtra(t.events.detail.dj(name: dj), appPrimary))
              .toList();
          return ProgramSlotData(
            time: timeStr,
            title: part.name,
            description: part.description ?? '',
            extras: [...lectorExtras, ...djExtras],
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildEventContent(Event event) {
    // Direct price field (from the dedicated price field on the event)
    final directPrice = event.price?.isNotEmpty == true ? event.price : null;

    final dresscodeInfo = event.info
        .where((i) => i.type == EventInfoType.dresscode)
        .firstOrNull;
    final dresscode = dresscodeInfo?.value ?? '';

    // All price entries displayed with their own key as label
    final priceEntries = event.info
        .where((i) => i.type == EventInfoType.price)
        .where((i) => i.key.isNotEmpty || i.value.isNotEmpty)
        .map((i) => MapEntry(i.key, i.value))
        .toList();

    // Use direct price as the main priceRange for the hero badge
    final priceRange = directPrice ?? (priceEntries.isNotEmpty ? priceEntries.first.value : '');

    // Collect non-price, non-dresscode entries
    final extraInfoEntries = <MapEntry<String, String>>[];
    // Add all price entries with their custom keys (e.g. "Price in advance", "Price on the day")
    extraInfoEntries.addAll(priceEntries);
    // Add remaining entries
    for (final i in event.info) {
      if (i.type == EventInfoType.price) continue;
      if (i.type == EventInfoType.dresscode) continue;
      if (i.key.isNotEmpty || i.value.isNotEmpty) {
        extraInfoEntries.add(MapEntry(i.key, i.value));
      }
    }

    return BlocBuilder<FavoritesCubit, dynamic>(
      builder: (context, _) {
        final isFavorited = context
            .read<FavoritesCubit>()
            .isFavorited('event', event.id);
        final isAuthenticated = context
            .read<AuthCubit>()
            .state
            .maybeMap(
              authenticated: (_) => true,
              orElse: () => false,
            );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              HeroImageSection(
                imageUrl: event.imageUrl ?? '',
                topLeft: priceRange.isNotEmpty
                    ? HeroPriceBadge(price: priceRange)
                    : null,
                topRight: isAuthenticated
                    ? HeroFavoriteButton(
                        isFavorite: isFavorited,
                        onTap: () => context
                            .read<FavoritesCubit>()
                            .toggleFavorite(
                              itemType: 'event',
                              itemId: event.id,
                            ),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    EventTitleSection(
                      title: event.title,
                      chips: event.dances
                          .map((d) => EventTitleChip(
                                label: d,
                                color: appPrimary,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    KeyInfoSection(
                      items: _buildKeyInfo(event),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ActionButtonsSection(
                      onShare: null,
                      onMap: event.venue != null &&
                              (event.venue!.latitude != 0 ||
                                  event.venue!.longitude != 0 ||
                                  event.venue!.fullAddress.isNotEmpty)
                          ? () => openMap(
                                event.venue!.latitude,
                                event.venue!.longitude,
                                event.venue!.name,
                                fullAddress: event.venue!.fullAddress,
                              )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (event.description.isNotEmpty)
                      DescriptionSection(
                        title: t.events.detail.description,
                        paragraphs: event.description
                            .split('\n\n')
                            .where((p) => p.trim().isNotEmpty)
                            .toList(),
                      ),
                    if (priceRange.isNotEmpty ||
                        dresscode.isNotEmpty ||
                        extraInfoEntries.isNotEmpty ||
                        event.registrationUrl != null ||
                        event.originalUrl != null) ...[
                      if (event.description.isNotEmpty)
                        const SizedBox(height: AppSpacing.xxl),
                      AdditionalInfoSection(
                        priceRange: priceRange,
                        dresscode: dresscode,
                        extraEntries: extraInfoEntries,
                        onBuyTickets: event.registrationUrl != null && event.registrationUrl!.isNotEmpty
                            ? () => openUrl(event.registrationUrl!)
                            : null,
                        onSource: event.originalUrl != null ? () => openUrl(event.originalUrl!) : null,
                      ),
                    ],
                    if (event.parts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      EventProgramSection(
                        days: _buildProgram(event.parts),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          BlocBuilder<EditorModeCubit, EditorModeState>(
            builder: (context, editorState) {
              final isEditorMode = editorState.isEditorMode && editorState.isEditor;

              List<Widget>? actions;
              if (isEditorMode) {
                actions = [
                  BlocBuilder<EventDetailCubit, EventDetailState>(
                    builder: (context, detailState) {
                      final event = detailState.maybeMap(
                        loaded: (s) => s.event,
                        success: (s) => s.event,
                        error: (s) => s.event,
                        orElse: () => null,
                      );
                      if (event == null) return const SizedBox.shrink();
                      final locale = Localizations.localeOf(context).languageCode;
                      final detailCubit = context.read<EventDetailCubit>();
                      return PopupMenuButton<String>(
                        icon: Container(
                          width: AppSizes.iconButtonMd,
                          height: AppSizes.iconButtonMd,
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                          child: const Center(
                            child: FaIcon(FontAwesomeIcons.ellipsisVertical, size: AppIconSizes.xs, color: appText),
                          ),
                        ),
                        color: appSurface,
                        onSelected: (value) async {
                          switch (value) {
                            case 'reload':
                              await detailCubit.refreshEvent(widget.eventId, locale);
                              if (mounted) {
                                context.read<EventCubit>().loadEvents(locale);
                              }
                            case 'review':
                              await detailCubit.toggleReviewed(widget.eventId, locale);
                              if (mounted) {
                                context.read<EventCubit>().loadEvents(locale);
                              }
                            case 'publish':
                              await detailCubit.togglePublished(widget.eventId, locale);
                              if (mounted) {
                                context.read<EventCubit>().loadEvents(locale);
                              }
                            case 'edit':
                              await EditEventRoute(id: widget.eventId).push(context);
                              if (mounted) {
                                detailCubit.refreshEvent(widget.eventId, locale);
                                context.read<EventCubit>().loadEvents(locale);
                              }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'reload',
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.arrowsRotate,
                                  size: AppIconSizes.xs,
                                  color: appText,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  t.editor.reload,
                                  style: const TextStyle(color: appText),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'review',
                            child: Row(
                              children: [
                                FaIcon(
                                  event.reviewed
                                      ? FontAwesomeIcons.solidSquareCheck
                                      : FontAwesomeIcons.square,
                                  size: AppIconSizes.xs,
                                  color: event.reviewed ? appSuccess : appMuted,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  event.reviewed ? t.editor.markAsUnreviewed : t.editor.markAsReviewed,
                                  style: const TextStyle(color: appText),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'publish',
                            child: Row(
                              children: [
                                FaIcon(
                                  event.published
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                  size: AppIconSizes.xs,
                                  color: event.published ? appError : appSuccess,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  event.published ? t.editor.unpublish : t.editor.publish,
                                  style: const TextStyle(color: appText),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.penToSquare,
                                  size: AppIconSizes.xs,
                                  color: appText,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  t.common.edit,
                                  style: const TextStyle(color: appText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ];
              }

              return DetailHeaderSection(
                title: t.events.detail.header,
                onBack: () => context.pop(),
                actions: actions,
              );
            },
          ),
          Expanded(
            child: BlocBuilder<EventDetailCubit, EventDetailState>(
              builder: (context, state) {
                final event = state.maybeMap(
                  loaded: (s) => s.event,
                  editing: (s) => s.event,
                  success: (s) => s.event,
                  submitting: (s) => s.event,
                  error: (s) => s.event,
                  orElse: () => null,
                );

                if (event == null) {
                  return state.maybeMap(
                    loading: (_) => const Center(
                      child: CircularProgressIndicator(color: appPrimary),
                    ),
                    orElse: () => Center(
                      child: Text(
                        t.events.detail.notFound,
                        style: const TextStyle(color: appMuted),
                      ),
                    ),
                  );
                }

                return _buildEventContent(event);
              },
            ),
          ),
        ],
      ),
    );
  }
}
