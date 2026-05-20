import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/tfi_responsive.dart';
import 'tfi_network_image.dart';
import 'tfi_poster_placeholder.dart';

/// Dark gradient scaffold wrapper.
class TfiScaffold extends StatelessWidget {
  const TfiScaffold({super.key, required this.child, this.bottom, this.appBar});
  final Widget child;
  final Widget? bottom;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: TfiTokens.screenBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: bottom,
      ),
    );
  }
}

class TfiHomeTopBar extends StatelessWidget {
  const TfiHomeTopBar({
    super.key,
    this.onSearch,
    this.onNotifications,
    this.notifCount = 0,
    this.subtitle = 'Today in TFI',
  });

  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final int notifCount;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 8, TfiTokens.padScreen, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TFI BAGUNDALI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TfiTokens.display(18, color: TfiTokens.gold),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TfiTokens.telugu(11, color: TfiTokens.textLo),
                ),
              ],
            ),
          ),
          if (onSearch != null)
            _iconBtn(Icons.search_rounded, onSearch!),
          if (onNotifications != null) ...[
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _iconBtn(Icons.notifications_outlined, onNotifications!),
                if (notifCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: TfiTokens.fire, shape: BoxShape.circle),
                      child: Text('$notifCount', style: TfiTokens.body(9, color: Colors.white, w: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: TfiTokens.glass,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TfiTokens.line),
          ),
          child: Icon(icon, size: 20, color: TfiTokens.textMid),
        ),
      ),
    );
  }
}

class TfiSectionHeader extends StatelessWidget {
  const TfiSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, TfiTokens.gapSection, TfiTokens.padScreen, TfiTokens.gapItem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TfiTokens.title(17, w: FontWeight.w800),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TfiTokens.telugu(11, color: TfiTokens.textLo),
                  ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!, style: TfiTokens.body(12, color: TfiTokens.gold, w: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class TfiCard extends StatelessWidget {
  const TfiCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.margin,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen, vertical: 6),
      padding: padding ?? const EdgeInsets.all(TfiTokens.padCard),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? TfiTokens.card1.withValues(alpha: 0.92) : null,
        borderRadius: BorderRadius.circular(TfiTokens.rCard),
        border: Border.all(color: TfiTokens.lineStrong),
        boxShadow: TfiTokens.cardShadow(opacity: 0.3),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

class TfiBadge extends StatelessWidget {
  const TfiBadge(this.label, {super.key, this.variant});
  final String label;
  final String? variant;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors(variant ?? label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TfiTokens.rChip),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TfiTokens.body(9, color: color, w: FontWeight.w800),
      ),
    );
  }

  (Color, Color) _colors(String v) {
    final u = v.toUpperCase();
    if (u.contains('OFFICIAL')) return (TfiTokens.stOfficial, TfiTokens.stOfficial.withValues(alpha: 0.15));
    if (u.contains('VERIFIED')) return (TfiTokens.stVerified, TfiTokens.stVerified.withValues(alpha: 0.15));
    if (u.contains('BREAKING')) return (TfiTokens.red, TfiTokens.red.withValues(alpha: 0.15));
    if (u.contains('BUZZ')) return (TfiTokens.stBuzz, TfiTokens.stBuzz.withValues(alpha: 0.15));
    if (u.contains('FREE')) return (TfiTokens.green, TfiTokens.green.withValues(alpha: 0.15));
    if (u.contains('QUIZ')) return (TfiTokens.blue, TfiTokens.blue.withValues(alpha: 0.15));
    if (u.contains('POLL')) return (TfiTokens.purple, TfiTokens.purple.withValues(alpha: 0.15));
    return (TfiTokens.gold, TfiTokens.gold.withValues(alpha: 0.12));
  }
}

class TfiPrimaryButton extends StatelessWidget {
  const TfiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(TfiTokens.rBtn),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed == null && !loading ? null : TfiTokens.gradGold,
            color: onPressed == null && !loading ? TfiTokens.textLo.withValues(alpha: 0.3) : null,
            borderRadius: BorderRadius.circular(TfiTokens.rBtn),
            boxShadow: onPressed == null ? null : TfiTokens.cardShadow(opacity: 0.2),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A0F00)),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[Icon(icon, size: 18, color: const Color(0xFF1A0F00)), const SizedBox(width: 8)],
                      Text(label, style: TfiTokens.body(15, color: const Color(0xFF1A0F00), w: FontWeight.w800)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class TfiSecondaryButton extends StatelessWidget {
  const TfiSecondaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TfiTokens.glass,
      borderRadius: BorderRadius.circular(TfiTokens.rBtn),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TfiTokens.rBtn),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TfiTokens.rBtn),
            border: Border.all(color: TfiTokens.lineStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: TfiTokens.textMid), const SizedBox(width: 6)],
              Text(label, style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class TfiImageCard extends StatelessWidget {
  const TfiImageCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.badge,
    this.height = 200,
    this.onTap,
    this.placeholderKind = TfiPlaceholderKind.update,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? badge;
  final double height;
  final VoidCallback? onTap;
  final TfiPlaceholderKind placeholderKind;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cardHeight = height > 0 ? height : TfiResponsive.heroImageCardHeight(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = cardHeight;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen, vertical: 6),
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TfiTokens.rHero),
              boxShadow: TfiTokens.cardShadow(),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TfiTokens.rHero),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TfiNetworkImage(
                    url: imageUrl,
                    fit: BoxFit.cover,
                    placeholderKind: placeholderKind,
                    placeholderTitle: title,
                    placeholderSubtitle: subtitle,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE6070914), Color(0xF2070914)],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (badge != null) ...[TfiBadge(badge!), const SizedBox(height: 8)],
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TfiTokens.title(16, w: FontWeight.w800),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TfiTokens.body(12, color: TfiTokens.textMid),
                              ),
                            ],
                            if (footer != null) ...[const SizedBox(height: 8), footer!],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TfiReactionRow extends StatelessWidget {
  const TfiReactionRow({super.key, this.counts});
  final Map<String, int>? counts;

  static const _labels = {
    'fire': '🔥',
    'mass': '💥',
    'love': '❤️',
    'wait': '⏳',
  };

  @override
  Widget build(BuildContext context) {
    final c = counts ?? {};
    final total = c['total'] ?? c.values.fold<int>(0, (a, b) => a + b);
    if (total == 0 && c.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ..._labels.entries.map((e) {
          final n = c[e.key] ?? 0;
          if (n == 0) return const SizedBox.shrink();
          return Text('${e.value} $n', style: TfiTokens.body(10, color: TfiTokens.textLo));
        }),
        if (total > 0) Text('$total reactions', style: TfiTokens.body(10, color: TfiTokens.textLo)),
      ],
    );
  }
}

class TfiShimmerCard extends StatelessWidget {
  const TfiShimmerCard({super.key, this.height = 120});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen, vertical: 6),
      height: height,
      decoration: BoxDecoration(
        color: TfiTokens.card1,
        borderRadius: BorderRadius.circular(TfiTokens.rCard),
      ),
    );
  }
}

class TfiCountdownChip extends StatelessWidget {
  const TfiCountdownChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: TfiTokens.gradFire,
        borderRadius: BorderRadius.circular(TfiTokens.rChip),
      ),
      child: Text(label, style: TfiTokens.body(11, color: Colors.white, w: FontWeight.w800)),
    );
  }
}

class TfiTagChip extends StatelessWidget {
  const TfiTagChip({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: TfiTokens.glass,
          borderRadius: BorderRadius.circular(TfiTokens.rChip),
          border: Border.all(color: TfiTokens.line),
        ),
        child: Text(label, style: TfiTokens.body(12, color: TfiTokens.textMid, w: FontWeight.w600)),
      ),
    );
  }
}

class TfiGlassPanel extends StatelessWidget {
  const TfiGlassPanel({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: TfiTokens.glassCard(radius: TfiTokens.rCard),
      child: child,
    );
  }
}

/// Horizontally scrollable filter chips (Explore, Polls, etc.).
class TfiFilterChipRow extends StatelessWidget {
  const TfiFilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: active ? TfiTokens.gradGold : null,
                color: active ? null : TfiTokens.glass,
                borderRadius: BorderRadius.circular(TfiTokens.rChip),
                border: Border.all(color: active ? TfiTokens.gold.withValues(alpha: 0.5) : TfiTokens.line),
              ),
              child: Text(
                labels[i],
                style: TfiTokens.body(12, color: active ? const Color(0xFF1A0F00) : TfiTokens.textMid, w: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Poster grid cell for wallpapers / status cards.
class TfiExplorePosterCell extends StatelessWidget {
  const TfiExplorePosterCell({
    super.key,
    required this.title,
    this.imageUrl,
    this.onTap,
    this.placeholderKind = TfiPlaceholderKind.wallpaper,
    this.aspectRatio = 0.72,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback? onTap;
  final TfiPlaceholderKind placeholderKind;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TfiTokens.rCard),
          border: Border.all(color: TfiTokens.lineStrong),
          boxShadow: TfiTokens.cardShadow(opacity: 0.25),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TfiNetworkImage(
                    url: imageUrl,
                    fit: BoxFit.cover,
                    darkOverlay: true,
                    placeholderKind: placeholderKind,
                    placeholderTitle: title,
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TfiTokens.body(11, color: Colors.white, w: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        TfiBadge('FREE'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TfiDetailAppBar extends StatelessWidget {
  const TfiDetailAppBar({super.key, required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, TfiTokens.padScreen, 8),
      child: Row(
        children: [
          Material(
            color: TfiTokens.glass,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TfiTokens.line),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: TfiTokens.textHi),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TfiTokens.title(18, w: FontWeight.w800))),
        ],
      ),
    );
  }
}
