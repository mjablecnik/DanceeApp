import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/colors.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme.dart';
import '../../../data/entities/dance_style.dart';
import '../../../data/repositories/dance_style_repository.dart';
import '../../../i18n/strings.g.dart';

class DanceStyleSelectorPage extends StatefulWidget {
  const DanceStyleSelectorPage({
    super.key,
    required this.initialSelection,
  });

  final List<String> initialSelection;

  @override
  State<DanceStyleSelectorPage> createState() => _DanceStyleSelectorPageState();
}

class _DanceStyleSelectorPageState extends State<DanceStyleSelectorPage> {
  List<DanceStyle> _styles = [];
  Map<String, bool> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    final languageCode = LocaleSettings.currentLocale.languageCode;
    final styles = await sl<DanceStyleRepository>().getDanceStyles(languageCode);
    styles.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      _styles = styles;
      _selected = {
        for (final s in styles) s.code: widget.initialSelection.contains(s.code),
      };
      _loading = false;
    });
  }

  int get _selectedCount => _selected.values.where((v) => v).length;

  void _clearAll() => setState(() {
        for (final key in _selected.keys) {
          _selected[key] = false;
        }
      });

  void _confirm() {
    final codes = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    context.pop(codes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _Header(
            selectedCount: _selectedCount,
            onBack: () => context.pop(null),
            onClear: _clearAll,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xxl,
                      AppSpacing.xl,
                      120,
                    ),
                    child: _StylesList(
                      styles: _styles,
                      selected: _selected,
                      onToggle: (code) =>
                          setState(() => _selected[code] = !(_selected[code] ?? false)),
                    ),
                  ),
          ),
        ],
      ),
      bottomSheet: _ConfirmButton(
        selectedCount: _selectedCount,
        onConfirm: _confirm,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const _Header({
    required this.selectedCount,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: AppSizes.iconButtonMd,
              height: AppSizes.iconButtonMd,
              decoration: const BoxDecoration(
                color: appSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.arrowLeft, size: AppIconSizes.xs, color: appText),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.events.danceStyles,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize3xl,
                    fontWeight: AppTypography.fontWeightBold,
                    color: appText,
                  ),
                ),
                Text(
                  t.events.filter.selectedCount(count: selectedCount),
                  style: const TextStyle(
                    fontSize: AppTypography.fontSizeMd,
                    color: appMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: Text(
              t.common.clear,
              style: const TextStyle(
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
                color: appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StylesList extends StatelessWidget {
  final List<DanceStyle> styles;
  final Map<String, bool> selected;
  final ValueChanged<String> onToggle;

  const _StylesList({
    required this.styles,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (styles.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(styles.length, (index) {
          final style = styles[index];
          final isLast = index == styles.length - 1;
          final isChecked = selected[style.code] ?? false;
          return _StyleRow(
            style: style,
            isChecked: isChecked,
            isLast: isLast,
            onToggle: () => onToggle(style.code),
          );
        }),
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  final DanceStyle style;
  final bool isChecked;
  final bool isLast;
  final VoidCallback onToggle;

  const _StyleRow({
    required this.style,
    required this.isChecked,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: appBorder)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconButtonMd,
              height: AppSizes.iconButtonMd,
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: AppOpacity.subtle),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.music, color: appPrimary, size: AppIconSizes.xs),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                style.name,
                style: const TextStyle(
                  fontSize: AppTypography.fontSizeXl,
                  fontWeight: AppTypography.fontWeightSemiBold,
                  color: appText,
                ),
              ),
            ),
            _Checkbox(isChecked: isChecked, onToggle: onToggle),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onToggle;

  const _Checkbox({required this.isChecked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? appPrimary : appSurface,
          border: Border.all(
            color: isChecked ? appPrimary : appBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: isChecked
            ? const Icon(FontAwesomeIcons.check, size: 12, color: Colors.white)
            : null,
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onConfirm;

  const _ConfirmButton({required this.selectedCount, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appBg.withValues(alpha: 0),
            appBg,
            appBg,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
      ),
      child: GestureDetector(
        onTap: onConfirm,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: appPrimary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [AppShadows.primaryLg],
          ),
          child: Text(
            selectedCount > 0
                ? t.events.filter.applyCount(count: selectedCount)
                : t.events.filter.apply,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeXl,
              fontWeight: AppTypography.fontWeightBold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
