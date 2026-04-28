import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography definitions for the Dancee App design system.
///
/// All text styles used across the app are defined here.
/// Use these styles instead of inline GoogleFonts.inter() calls.
///
/// Categories:
/// - Display: titles and headings (large, medium, small)
/// - Body: content text (large, medium, small)
/// - Label: buttons, links, captions (large, medium, small)
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // Display styles – titles and headings
  // ---------------------------------------------------------------------------

  /// Large display text (32px bold). Use for hero titles.
  static final TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  /// Medium display text (24px bold). Use for page titles (e.g. "Favorite Events").
  static final TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// Small display text (20px bold). Use for section titles (e.g. "No Favorite Events").
  static final TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Body styles – content text
  // ---------------------------------------------------------------------------

  /// Large body text (16px regular). Use for primary content and descriptions.
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Medium body text (14px regular). Use for secondary content and descriptions.
  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Small body text (12px regular). Use for tertiary content and metadata.
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // ---------------------------------------------------------------------------
  // Label styles – buttons, links, captions
  // ---------------------------------------------------------------------------

  /// Large label text (14px semi-bold). Use for buttons and links.
  static final TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Medium label text (12px semi-bold). Use for chips, badges, and captions.
  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Small label text (10px semi-bold). Use for tiny badges and annotations.
  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}
