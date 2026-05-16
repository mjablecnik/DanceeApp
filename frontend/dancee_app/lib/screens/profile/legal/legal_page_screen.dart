import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/back_button_header.dart';

class LegalPageScreen extends StatefulWidget {
  final String slug;
  final String title;

  const LegalPageScreen({
    super.key,
    required this.slug,
    required this.title,
  });

  @override
  State<LegalPageScreen> createState() => _LegalPageScreenState();
}

class _LegalPageScreenState extends State<LegalPageScreen> {
  late Future<String> _contentFuture;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    final languageCode = LocaleSettings.currentLocale.languageCode;
    _contentFuture = sl<ProfileRepository>().getLegalContent(widget.slug, languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          BackButtonHeader(
            title: widget.title,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: _contentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: appPrimary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.profile.legalPage.error,
                            style: const TextStyle(
                              color: appMuted,
                              fontSize: AppTypography.fontSizeMd,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextButton(
                            onPressed: () => setState(_loadContent),
                            child: Text(
                              t.profile.legalPage.retry,
                              style: const TextStyle(color: appPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final content = snapshot.data ?? '';
                return Markdown(
                  data: content,
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: AppSpacing.xl,
                    bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                  ),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: appText, fontSize: AppTypography.fontSizeMd, height: AppLineHeights.relaxed),
                    h1: const TextStyle(color: appText, fontSize: AppTypography.fontSizeXl, fontWeight: FontWeight.bold),
                    h2: const TextStyle(color: appText, fontSize: AppTypography.fontSizeLg, fontWeight: FontWeight.bold),
                    h3: const TextStyle(color: appText, fontSize: AppTypography.fontSizeMd, fontWeight: FontWeight.bold),
                    listBullet: const TextStyle(color: appText, fontSize: AppTypography.fontSizeMd),
                    blockquoteDecoration: const BoxDecoration(
                      color: appSurface,
                      border: Border(left: BorderSide(color: appBorder, width: AppBorders.thick)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
