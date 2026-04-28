import 'package:dancee_app/design/typography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // =========================================================================
  // TC-M08: AppTypography key text style font sizes
  // =========================================================================

  testWidgets('TC-M08: displayLarge has fontSize 32', (tester) async {
    expect(AppTypography.displayLarge.fontSize, equals(32));
  });

  testWidgets('TC-M08: bodyMedium has fontSize 14', (tester) async {
    expect(AppTypography.bodyMedium.fontSize, equals(14));
  });

  testWidgets('TC-M08: labelSmall has fontSize 10', (tester) async {
    expect(AppTypography.labelSmall.fontSize, equals(10));
  });

  // =========================================================================
  // Task 61: displayMedium has fontSize 24; displaySmall has fontSize 20
  // =========================================================================

  test('TC-T61a: displayMedium has fontSize 24', () {
    expect(AppTypography.displayMedium.fontSize, equals(24.0));
  });

  test('TC-T61b: displaySmall has fontSize 20', () {
    expect(AppTypography.displaySmall.fontSize, equals(20.0));
  });

  // =========================================================================
  // Task 62: bodyLarge has fontSize 16; bodySmall has fontSize 12
  // =========================================================================

  test('TC-T62a: bodyLarge has fontSize 16', () {
    expect(AppTypography.bodyLarge.fontSize, equals(16.0));
  });

  test('TC-T62b: bodySmall has fontSize 12', () {
    expect(AppTypography.bodySmall.fontSize, equals(12.0));
  });

  // =========================================================================
  // Task 63: labelLarge has fontSize 14; labelMedium has fontSize 12
  // =========================================================================

  test('TC-T63a: labelLarge has fontSize 14', () {
    expect(AppTypography.labelLarge.fontSize, equals(14.0));
  });

  test('TC-T63b: labelMedium has fontSize 12', () {
    expect(AppTypography.labelMedium.fontSize, equals(12.0));
  });
}
