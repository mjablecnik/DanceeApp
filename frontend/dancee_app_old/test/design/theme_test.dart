import 'package:dancee_app/design/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Disable network fetching so Google Fonts uses bundled fallback fonts
    // without requiring network access.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // =========================================================================
  // TC-L13: AppTheme.lightTheme returns valid ThemeData with useMaterial3
  // =========================================================================

  testWidgets(
    'TC-L13: AppTheme.lightTheme returns non-null ThemeData with useMaterial3 == true',
    (WidgetTester tester) async {
      final theme = AppTheme.lightTheme;

      expect(theme, isNotNull);
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue,
          reason: 'AppTheme must use Material 3 design system');
    },
  );
}
