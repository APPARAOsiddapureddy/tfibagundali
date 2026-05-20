import 'package:flutter/material.dart';

/// Layout helpers for phone-width UI (including web preview frame).
abstract final class TfiResponsive {
  static const double webFrameMaxWidth = 430;
  static const double tabBarHeight = 64;

  static double contentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w > webFrameMaxWidth ? webFrameMaxWidth : w;
  }

  /// Space above bottom tab bar + safe area.
  static double scrollBottomPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + tabBarHeight + 16;
  }

  static double horizontalCardWidth(BuildContext context) {
    final w = contentWidth(context);
    return (w * 0.82).clamp(280.0, 340.0);
  }

  static double horizontalRailHeight(BuildContext context) => 228;

  static double heroImageCardHeight(BuildContext context) {
    final w = contentWidth(context) - 32;
    return (w * 0.52).clamp(200.0, 260.0);
  }

  static double moviePosterTileWidth(BuildContext context) => 148;

  static double exploreThumbWidth(BuildContext context) => 112;
}
