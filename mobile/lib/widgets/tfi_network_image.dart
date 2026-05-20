import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_tokens.dart';
import 'tfi_poster_placeholder.dart';

class TfiNetworkImage extends StatelessWidget {
  const TfiNetworkImage({
    super.key,
    this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.darkOverlay = false,
    this.placeholderKind = TfiPlaceholderKind.generic,
    this.placeholderTitle,
    this.placeholderSubtitle,
  });

  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool darkOverlay;
  final TfiPlaceholderKind placeholderKind;
  final String? placeholderTitle;
  final String? placeholderSubtitle;

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(TfiTokens.rCard);
    Widget child;
    if (!_hasUrl) {
      child = TfiPosterPlaceholder(
        kind: placeholderKind,
        title: placeholderTitle,
        subtitle: placeholderSubtitle,
        height: height,
        width: width,
        borderRadius: radius,
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: url!,
        height: height,
        width: width,
        fit: fit,
        placeholder: (_, _) => _shimmer(radius),
        errorWidget: (_, _, _) => TfiPosterPlaceholder(
          kind: placeholderKind,
          title: placeholderTitle,
          subtitle: placeholderSubtitle,
          height: height,
          width: width,
          borderRadius: radius,
        ),
      );
    }

    child = ClipRRect(borderRadius: radius, child: child);

    if (height != null || width != null) {
      child = SizedBox(height: height, width: width, child: child);
    } else {
      child = SizedBox.expand(child: child);
    }

    if (darkOverlay && _hasUrl) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          child,
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: TfiTokens.gradCardOverlay,
            ),
          ),
        ],
      );
    }

    return child;
  }

  Widget _shimmer(BorderRadius radius) {
    return Shimmer.fromColors(
      baseColor: TfiTokens.card2,
      highlightColor: TfiTokens.card3,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: TfiTokens.card1,
          borderRadius: radius,
        ),
      ),
    );
  }
}
