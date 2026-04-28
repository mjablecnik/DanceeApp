import 'package:dancee_app/features/app/pages/error_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  // =========================================================================
  // TC-147: ErrorPage displays the provided error message
  // =========================================================================

  testWidgets('TC-147: ErrorPage displays the provided error message',
      (tester) async {
    await tester.pumpWidget(_wrap(const ErrorPage(
      message: 'Unexpected failure',
    )));

    expect(find.text('Unexpected failure'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  // =========================================================================
  // Task 66: ErrorPage — no retry button when onRetry is null
  // =========================================================================

  testWidgets('TC-T66: ErrorPage does not render retry button when onRetry is null',
      (tester) async {
    await tester.pumpWidget(_wrap(const ErrorPage(
      message: 'Oops',
    )));

    expect(find.byType(ElevatedButton), findsNothing);
  });

  // =========================================================================
  // TC-148: ErrorPage renders retry button and fires onRetry callback on tap
  // =========================================================================

  testWidgets(
      'TC-148: ErrorPage renders retry button and fires onRetry callback on tap',
      (tester) async {
    var retried = false;

    await tester.pumpWidget(_wrap(ErrorPage(
      message: 'Error',
      onRetry: () => retried = true,
    )));

    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(retried, isTrue);
  });
}
