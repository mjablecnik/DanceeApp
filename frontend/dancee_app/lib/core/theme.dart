import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: appBg,
      colorScheme: const ColorScheme.dark(
        surface: appSurface,
        primary: appPrimary,
        secondary: appAccent,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: appText,
        displayColor: appText,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: appMuted),
      ),
    );
  }
}

class AppTypography {
  // Font sizes
  static const double fontSizeXs = 10;
  static const double fontSizeSm = 12;
  static const double fontSizeMd = 14;
  static const double fontSizeLg = 15;
  static const double fontSizeXl = 16;
  static const double fontSize2xl = 18;
  static const double fontSize3xl = 20;
  static const double fontSize4xl = 24;
  static const double fontSize5xl = 28;
  static const double fontSize6xl = 36;

  // Font weights
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Text style presets
  static const TextStyle headingXl = TextStyle(
    fontSize: fontSize6xl,
    fontWeight: fontWeightBold,
    color: appText,
  );

  static const TextStyle headingLg = TextStyle(
    fontSize: fontSize5xl,
    fontWeight: fontWeightBold,
    color: appText,
  );

  static const TextStyle headingMd = TextStyle(
    fontSize: fontSize4xl,
    fontWeight: fontWeightBold,
    color: appText,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: fontSize3xl,
    fontWeight: fontWeightSemiBold,
    color: appText,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: fontSize2xl,
    fontWeight: fontWeightSemiBold,
    color: appText,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightNormal,
    color: appText,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightNormal,
    color: appText,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    color: appText,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightMedium,
    color: appText,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    color: appText,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double round = 20;
  static const double xxl = 24;
  static const double full = 50;
}

class AppShadows {
  static final BoxShadow primary = BoxShadow(
    color: appPrimary.withValues(alpha: 0.5),
    blurRadius: 20,
    spreadRadius: -5,
  );

  static final BoxShadow primaryLg = BoxShadow(
    color: appPrimary.withValues(alpha: 0.5),
    blurRadius: 20,
    offset: const Offset(0, 5),
  );

  static final BoxShadow card = BoxShadow(
    color: Colors.black.withValues(alpha: 0.2),
    blurRadius: 20,
    spreadRadius: -5,
  );
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [appPrimary, appAccent],
  );

  static const LinearGradient premium = LinearGradient(
    colors: [appPrimary, appAccent, appPink],
  );

  static LinearGradient heroOverlay = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black38,
      Colors.transparent,
    ],
  );

  static LinearGradient premiumSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      appPrimary.withValues(alpha: 0.2),
      appAccent.withValues(alpha: 0.2),
      appPink.withValues(alpha: 0.2),
    ],
  );
}
