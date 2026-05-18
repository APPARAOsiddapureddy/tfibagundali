import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from css/tokens.css + css/src/tokens.js
abstract final class TfiTokens {
  static const bg0 = Color(0xFF07080F);
  static const bg1 = Color(0xFF0B0D17);
  static const bg2 = Color(0xFF12152A);
  static const bg3 = Color(0xFF1B1F38);
  static const line = Color(0x14FFFFFF);
  static const lineStrong = Color(0x29FFFFFF);

  static const gold = Color(0xFFF5A524);
  static const goldHot = Color(0xFFFFB52E);
  static const orange = Color(0xFFFF6A1F);
  static const fire = Color(0xFFFF7A1A);
  static const fireDeep = Color(0xFFE63950);
  static const red = Color(0xFFE5484D);
  static const pink = Color(0xFFE93D82);
  static const purple = Color(0xFF8B5CF6);
  static const blue = Color(0xFF3E8BFF);
  static const cyan = Color(0xFF22D3EE);
  static const green = Color(0xFF30C76C);

  static const textHi = Color(0xFFFFFFFF);
  static const textMid = Color(0xC7FFFFFF);
  static const textLo = Color(0x8CFFFFFF);
  static const textFaint = Color(0x59FFFFFF);

  static const stOfficial = Color(0xFF30C76C);
  static const stVerified = Color(0xFF3E8BFF);
  static const stReport = Color(0xFFF5A524);
  static const stBuzz = Color(0xFFE93D82);

  static const coin = Color(0xFFFFC53D);
  static const points = Color(0xFFB981FF);

  static const rSm = 12.0;
  static const rMd = 16.0;
  static const rLg = 22.0;
  static const rXl = 28.0;

  static TextStyle display(double size, {Color? color, double? height}) =>
      GoogleFonts.bricolageGrotesque(fontSize: size, fontWeight: FontWeight.w800, color: color ?? textHi, height: height, letterSpacing: -0.5);

  static TextStyle body(double size, {Color? color, FontWeight w = FontWeight.w500}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color ?? textMid);

  static TextStyle telugu(double size, {Color? color}) =>
      GoogleFonts.notoSansTelugu(fontSize: size, fontWeight: FontWeight.w600, color: color ?? textMid);

  static const gradFire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB347), Color(0xFFFF7A1A), Color(0xFFE63950)],
  );

  static const gradGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE36B), Color(0xFFFFC83D), Color(0xFFF59E0B)],
  );

  static const gradMass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A1A), Color(0xFFE63950), Color(0xFF8B5CF6)],
  );

  static const gradPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC084FC), Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  static const screenBg = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -0.3),
      radius: 1.2,
      colors: [Color(0x331A1028), bg1],
    ),
  );
}
