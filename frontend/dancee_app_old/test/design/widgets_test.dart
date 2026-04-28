import 'package:dancee_app/design/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  // =========================================================================
  // TC-142: AppLoadingIndicator renders a CircularProgressIndicator
  // =========================================================================

  testWidgets('TC-142: AppLoadingIndicator renders a CircularProgressIndicator',
      (tester) async {
    await tester.pumpWidget(_wrap(const AppLoadingIndicator()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // =========================================================================
  // TC-143: AppErrorMessage renders error icon and message, no retry button
  // =========================================================================

  testWidgets(
      'TC-143: AppErrorMessage renders error icon and message text; no ElevatedButton when onRetry is null',
      (tester) async {
    await tester.pumpWidget(_wrap(const AppErrorMessage(
      message: 'Something went wrong',
    )));

    expect(find.byType(Icon), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  // =========================================================================
  // TC-144: AppErrorMessage with onRetry renders retry button and fires callback
  // =========================================================================

  testWidgets(
      'TC-144: AppErrorMessage renders retry button and fires onRetry callback on tap',
      (tester) async {
    var called = false;

    await tester.pumpWidget(_wrap(AppErrorMessage(
      message: 'Error',
      onRetry: () => called = true,
    )));

    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(called, isTrue);
  });

  // =========================================================================
  // TC-145: AppEmptyState renders icon, title, and description
  // =========================================================================

  testWidgets('TC-145: AppEmptyState renders icon, title, and description',
      (tester) async {
    await tester.pumpWidget(_wrap(const AppEmptyState(
      icon: Icons.search_off,
      title: 'No results',
      description: 'Try different filters',
    )));

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('No results'), findsOneWidget);
    expect(find.text('Try different filters'), findsOneWidget);
  });

  // =========================================================================
  // TC-146: AppEmptyState renders without description and does not crash
  // =========================================================================

  testWidgets(
      'TC-146: AppEmptyState renders without description without crashing',
      (tester) async {
    await tester.pumpWidget(_wrap(const AppEmptyState(
      icon: Icons.inbox,
      title: 'Empty',
    )));

    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
    expect(find.text('Try different filters'), findsNothing);
  });
}
