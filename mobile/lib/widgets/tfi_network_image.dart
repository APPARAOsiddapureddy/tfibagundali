import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

class TfiNetworkImage extends StatelessWidget {
  const TfiNetworkImage({
    super.key,
    this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    Widget child;
    if (url == null || url!.isEmpty) {
      child = _placeholder();
    } else {
      child = CachedNetworkImage(
        imageUrl: url!,
        height: height,
        width: width,
        fit: fit,
        placeholder: (_, _) => _placeholder(showSpinner: true),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return ClipRRect(borderRadius: radius, child: child);
  }

  Widget _placeholder({bool showSpinner = false}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TfiTokens.bg2, TfiTokens.fireDeep.withValues(alpha: 0.35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: showSpinner
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: TfiTokens.fire))
          : const Text('🎬', style: TextStyle(fontSize: 32)),
    );
  }
}
