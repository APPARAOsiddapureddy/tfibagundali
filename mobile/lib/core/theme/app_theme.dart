import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TfiTokens.bg1,
      colorScheme: const ColorScheme.dark(
        primary: TfiTokens.gold,
        secondary: TfiTokens.fire,
        surface: TfiTokens.bg2,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: TfiTokens.textHi,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
