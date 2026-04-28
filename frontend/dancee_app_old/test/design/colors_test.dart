import 'package:dancee_app/design/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // =========================================================================
  // Task 64: AppColors primary color and error color
  // =========================================================================

  test('TC-T64a: AppColors.primary is Color(0xFF6366F1)', () {
    expect(AppColors.primary, equals(const Color(0xFF6366F1)));
  });

  test('TC-T64b: AppColors.error is non-null', () {
    expect(AppColors.error, isNotNull);
  });
}
