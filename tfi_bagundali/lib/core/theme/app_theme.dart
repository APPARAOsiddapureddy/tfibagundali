import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Spacing
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;

  // Radius
  static const rCard = 14.0;
  static const rButton = 16.0;
  static const rChip = 20.0;
  static const rSplash = 44.0;

  static const bottomNavHeight = 56.0;
  static const bottomSafePadding = 20.0;

  // Typography
  static final headingLarge = GoogleFonts.anton(
    fontSize: 32,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
  );
  static final headingMedium = GoogleFonts.anton(
    fontSize: 24,
    color: AppColors.textPrimary,
  );
  static final headingSmall = GoogleFonts.anton(
    fontSize: 18,
    color: AppColors.textPrimary,
  );
  static final bodyLarge = GoogleFonts.barlow(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final bodyMedium = GoogleFonts.barlow(
    fontSize: 13,
    color: AppColors.textPrimary,
  );
  static final bodySmall = GoogleFonts.barlow(
    fontSize: 11,
    color: AppColors.textPrimary,
  );
  static final telugu = GoogleFonts.notoSansTelugu(
    fontSize: 13,
    color: AppColors.textPrimary,
  );
  static final coinNumber = GoogleFonts.anton(
    fontSize: 28,
    color: AppColors.gold,
  );
  static final countdown = GoogleFonts.anton(
    fontSize: 22,
    color: AppColors.red,
  );

  /// Emoji / icon sizing (not Google Fonts — avoids inline TextStyle in widgets).
  static TextStyle emoji(double size, {double? height}) =>
      TextStyle(fontSize: size, height: height);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.scaffold,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.red,
        secondary: AppColors.gold,
        surface: AppColors.bg2,
        onSurface: AppColors.textPrimary,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.bg4,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
      dividerColor: AppColors.border,
      textTheme: base.textTheme.copyWith(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelSmall: GoogleFonts.barlow(fontSize: 11, color: AppColors.textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg3,
        hintStyle: GoogleFonts.barlow(color: AppColors.textMuted2),
        labelStyle: GoogleFonts.barlow(color: AppColors.textMuted2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
    );
  }
}