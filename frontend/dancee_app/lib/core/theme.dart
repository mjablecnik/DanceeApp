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

class AppSizes {
  static const double buttonHeight = 56;
  static const double buttonHeightSm = 48;
  static const double iconButtonLg = 44;
  static const double iconButtonMd = 40;
  static const double iconButtonSm = 36;
  static const double avatarLg = 64;
  static const double avatarSm = 40;
  static const double heroHeight = 256;
  static const double carouselHeight = 340;
  static const double featuredCardWidth = 280;
  static const double featuredCardImageHeight = 160;
  static const double listCardImageSize = 96;
  static const double fabSize = 56;
  static const double checkboxSize = 20;
}

class AppIconSizes {
  static const double xl = 48;
  static const double lg = 32;
  static const double md = 24;
  static const double sm = 20;
  static const double xs = 16;
}

class AppBorders {
  static const double thick = 4;
  static const double medium = 2;
  static const double thin = 1;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 3000);
}

class AppLineHeights {
  static const double tight = 1.3;
  static const double normal = 1.5;
  static const double relaxed = 1.6;
}

class AppOpacity {
  static const double high = 0.9;
  static const double medium = 0.5;
  static const double low = 0.3;
  static const double subtle = 0.15;
  static const double faint = 0.1;
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
