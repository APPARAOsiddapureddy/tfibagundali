import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Shimmer placeholder matching common card sizes to avoid layout jump.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 14,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bg4,
      highlightColor: AppColors.bg3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bg4,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
