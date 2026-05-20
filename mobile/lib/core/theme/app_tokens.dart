import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TFI Cinematic Dark Theme — design tokens.
abstract final class TfiTokens {
  // Backgrounds
  static const bg0 = Color(0xFF070914);
  static const bg1 = Color(0xFF090B12);
  static const bg2 = Color(0xFF0D111C);
  static const card1 = Color(0xFF121622);
  static const card2 = Color(0xFF161B2A);
  static const card3 = Color(0xFF1A2033);

  static const line = Color(0x14FFFFFF);
  static const lineStrong = Color(0x29FFFFFF);
  static const glass = Color(0x0FFFFFFF);

  // Primary (gold / fire)
  static const gold = Color(0xFFFFB545);
  static const goldHot = Color(0xFFFF9F1C);
  static const orange = Color(0xFFFF6B21);
  static const fire = Color(0xFFFF6B21);
  static const fireDeep = Color(0xFFE63950);

  // Secondary
  static const purple = Color(0xFF7C4DFF);
  static const blue = Color(0xFF2F80ED);
  static const red = Color(0xFFFF3B3B);
  static const green = Color(0xFF22C55E);
  static const pink = Color(0xFFE93D82);
  static const cyan = Color(0xFF22D3EE);

  // Text
  static const textHi = Color(0xFFFFFFFF);
  static const textMid = Color(0xFFB7BBC8);
  static const textLo = Color(0xFF73788A);
  static const textFaint = Color(0x59FFFFFF);

  // Trust / status
  static const stOfficial = Color(0xFF22C55E);
  static const stVerified = Color(0xFF2F80ED);
  static const stReport = Color(0xFFFFB545);
  static const stBuzz = Color(0xFFE93D82);

  // Legacy aliases
  static const bg3 = card3;
  static const coin = gold;
  static const points = purple;

  // Ticket / auth screens (warm accent panels)
  static const ticketBg = Color(0xFFFFF5E0);
  static const ticketBgEnd = Color(0xFFFFE5B8);
  static const ticketDark = Color(0xFF1A0F00);
  static const ticketAccent = Color(0xFFB43A12);
  static const goldGlow = gold;
  static const goldWarm = Color(0xFFFFD7A0);

  // Radius
  static const rChip = 12.0;
  static const rCard = 18.0;
  static const rHero = 24.0;
  static const rSheet = 28.0;
  static const rBtn = 14.0;
  static const rSm = rChip;
  static const rMd = rCard;
  static const rLg = rHero;
  static const rXl = rSheet;

  // Spacing
  static const padScreen = 16.0;
  static const padCard = 16.0;
  static const gapSection = 22.0;
  static const gapItem = 12.0;

  static TextStyle display(double size, {Color? color, double? height, FontWeight? weight}) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w800,
        color: color ?? textHi,
        height: height,
        letterSpacing: -0.3,
      );

  static TextStyle title(double size, {Color? color, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.montserrat(fontSize: size, fontWeight: w, color: color ?? textHi);

  static TextStyle body(double size, {Color? color, FontWeight w = FontWeight.w500}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color ?? textMid);

  static TextStyle telugu(double size, {Color? color, FontWeight w = FontWeight.w600}) {
    final c = color ?? textMid;
    if (kIsWeb) {
      return body(size, color: c, w: w);
    }
    return GoogleFonts.notoSansTelugu(fontSize: size, fontWeight: w, color: c);
  }

  static TextStyle mono(double size, {Color? color, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, color: color ?? textHi);

  static const gradFire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB545), Color(0xFFFF9F1C), Color(0xFFFF6B21)],
  );

  static const gradGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD36B), Color(0xFFFFB545), Color(0xFFFF9F1C)],
  );

  static const gradMass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A1A), Color(0xFFE63950), Color(0xFF7C4DFF)],
  );

  static const gradPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC084FC), Color(0xFF7C4DFF), Color(0xFF6D28D9)],
  );

  static const gradCinematicBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bg0, bg1, bg2],
  );

  static const gradCardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC070914), Color(0xF2070914)],
    stops: [0.35, 0.75, 1.0],
  );

  static const screenBg = BoxDecoration(gradient: gradCinematicBg);

  static List<BoxShadow> cardShadow({double opacity = 0.35}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration glassCard({double radius = rCard}) => BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: lineStrong),
        boxShadow: cardShadow(opacity: 0.25),
      );
}
