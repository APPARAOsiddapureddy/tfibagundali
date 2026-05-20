import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

enum TfiPlaceholderKind { update, movie, hero, wallpaper, statusCard, quiz, poll, generic }

/// Cinematic placeholder when backend image URL is missing.
class TfiPosterPlaceholder extends StatelessWidget {
  const TfiPosterPlaceholder({
    super.key,
    this.kind = TfiPlaceholderKind.generic,
    this.title,
    this.subtitle,
    this.height,
    this.width,
    this.borderRadius,
    this.icon,
  });

  final TfiPlaceholderKind kind;
  final String? title;
  final String? subtitle;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(TfiTokens.rCard);
    final initials = _initials(title);
    final glow = _glowColor();

    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TfiTokens.card2,
            TfiTokens.bg2,
            glow.withValues(alpha: 0.25),
          ],
        ),
        border: Border.all(color: TfiTokens.lineStrong),
        boxShadow: [
          BoxShadow(color: glow.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: -4),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glow.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(icon ?? _defaultIcon(), color: glow.withValues(alpha: 0.9), size: 28),
                if (initials.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    initials,
                    style: TfiTokens.display(22, color: TfiTokens.textHi.withValues(alpha: 0.9)),
                  ),
                ],
                if (title != null && title!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TfiTokens.body(13, color: TfiTokens.textHi, w: FontWeight.w700),
                  ),
                ],
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TfiTokens.body(11, color: TfiTokens.textLo),
                  ),
                const SizedBox(height: 4),
                Text('TFI', style: TfiTokens.body(9, color: glow.withValues(alpha: 0.7), w: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _glowColor() {
    switch (kind) {
      case TfiPlaceholderKind.movie:
        return TfiTokens.gold;
      case TfiPlaceholderKind.hero:
        return TfiTokens.purple;
      case TfiPlaceholderKind.wallpaper:
      case TfiPlaceholderKind.statusCard:
        return TfiTokens.orange;
      case TfiPlaceholderKind.quiz:
        return TfiTokens.blue;
      case TfiPlaceholderKind.poll:
        return TfiTokens.pink;
      case TfiPlaceholderKind.update:
      case TfiPlaceholderKind.generic:
        return TfiTokens.fire;
    }
  }

  IconData _defaultIcon() {
    switch (kind) {
      case TfiPlaceholderKind.movie:
        return Icons.movie_rounded;
      case TfiPlaceholderKind.hero:
        return Icons.star_rounded;
      case TfiPlaceholderKind.wallpaper:
        return Icons.wallpaper_rounded;
      case TfiPlaceholderKind.statusCard:
        return Icons.style_rounded;
      case TfiPlaceholderKind.quiz:
        return Icons.quiz_rounded;
      case TfiPlaceholderKind.poll:
        return Icons.how_to_vote_rounded;
      case TfiPlaceholderKind.update:
      case TfiPlaceholderKind.generic:
        return Icons.theaters_rounded;
    }
  }

  String _initials(String? t) {
    if (t == null || t.trim().isEmpty) return '';
    final parts = t.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t[0].toUpperCase();
  }
}
