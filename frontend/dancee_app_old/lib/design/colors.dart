import 'package:flutter/material.dart';

/// Centralized color constants for the Dancee App design system.
///
/// All color definitions used across the app are defined here.
/// Use these constants instead of inline Color() definitions.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Primary colors
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4F46E5);

  // ---------------------------------------------------------------------------
  // Accent colors
  // ---------------------------------------------------------------------------
  static const Color accent = Color(0xFFEC4899);
  static const Color accentDark = Color(0xFFDB2777);
  static const Color accentLight = Color(0xFFF472B6);
  static const Color rose = Color(0xFFF43F5E);

  // ---------------------------------------------------------------------------
  // Neutral / text colors
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textBody = Color(0xFF475569);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // Background & surface colors
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color backgroundSlate = Color(0xFFF8FAFC);

  // ---------------------------------------------------------------------------
  // Semantic colors
  // ---------------------------------------------------------------------------
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningDarker = Color(0xFFB45309);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);

  // ---------------------------------------------------------------------------
  // Dance style colors
  // ---------------------------------------------------------------------------
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color violet = Color(0xFF7C3AED);
  static const Color orange = Color(0xFFF97316);
  static const Color yellow = Color(0xFFEAB308);

  // ---------------------------------------------------------------------------
  // Google brand color
  // ---------------------------------------------------------------------------
  static const Color google = Color(0xFFEA4335);

  // ---------------------------------------------------------------------------
  // Light background tints (used for icon backgrounds, cards, etc.)
  // ---------------------------------------------------------------------------

  // Indigo tints
  static const Color indigoLight = Color(0xFFEEF2FF);

  // Blue tints
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color blueMedium = Color(0xFFDBEAFE);
  static const Color blueBorder = Color(0xFFBFDBFE);

  // Violet tints
  static const Color violetLight = Color(0xFFF5F3FF);
  static const Color violetMedium = Color(0xFFEDE9FE);
  static const Color violetBorder = Color(0xFFD8B4FE);

  // Pink tints
  static const Color pinkLight = Color(0xFFFDF2F8);
  static const Color pinkMedium = Color(0xFFFCE7F3);
  static const Color pinkBorder = Color(0xFFFBCFE8);

  // Rose tints
  static const Color roseLight = Color(0xFFFFF1F2);

  // Green tints
  static const Color greenLightest = Color(0xFFF0FDF4);
  static const Color greenLighter = Color(0xFFECFDF5);
  static const Color greenLight = Color(0xFFD1FAE5);
  static const Color greenBorder = Color(0xFFBBF7D0);

  // Amber / warning tints
  static const Color amberLightest = Color(0xFFFFFBEB);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color amberBorder = Color(0xFFFDE68A);
  static const Color orangeLight = Color(0xFFFFF7ED);

  // Red / error tints
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------

  /// Primary gradient used in headers and prominent UI elements.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gradient used for primary action buttons and badges.
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gradient used for dark primary buttons (e.g. apply filters).
  static const LinearGradient primaryDarkGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Accent gradient used for decorative elements.
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light info-tinted gradient for card backgrounds.
  static const LinearGradient infoLightGradient = LinearGradient(
    colors: [blueLight, indigoLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light background gradient for subtle surfaces.
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [background, backgroundSlate],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light red gradient for destructive action areas.
  static const LinearGradient errorLightGradient = LinearGradient(
    colors: [redLight, roseLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light amber gradient for saved filters / bookmarks.
  static const LinearGradient warningLightGradient = LinearGradient(
    colors: [amberLightest, orangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
