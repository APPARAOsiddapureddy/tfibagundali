import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../data/army_data.dart';

class TfiScreen extends StatelessWidget {
  const TfiScreen({super.key, required this.child, this.bottom});
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: TfiTokens.screenBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: bottom,
      ),
    );
  }
}

class TfiTopBar extends StatelessWidget {
  const TfiTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.user = 'Rakesh',
    this.coins = '1,245',
    this.armyKey = 'power',
    this.notifs = 3,
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? trailing;
  final String user;
  final String coins;
  final String armyKey;
  final int notifs;

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: TfiTokens.display(28, color: TfiTokens.fire),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TfiTokens.body(
                        12,
                        color: TfiTokens.textLo,
                        w: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...trailing!,
          ],
        ),
      );
    }

    final a = ArmyData.get(armyKey);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          // ── Profile avatar (simple, no emoji badge) ──
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: a.gradient,
            ),
            alignment: Alignment.center,
            child: Text(
              user.isNotEmpty ? user[0].toUpperCase() : 'F',
              style: TfiTokens.display(14, color: Colors.white),
            ),
          ),

          // ── Center: App name ──
          Expanded(
            child: Center(
              child: Text(
                'TFI Bagundali',
                style: TfiTokens.display(17, color: TfiTokens.textHi),
              ),
            ),
          ),

          // ── Right: Notification bell ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TfiTokens.line),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.notifications_outlined,
                  size: 19,
                  color: TfiTokens.textMid,
                ),
              ),
              if (notifs > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      color: TfiTokens.fireDeep,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: TfiTokens.bg1, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$notifs',
                      style: TfiTokens.body(
                        10,
                        color: Colors.white,
                        w: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroAvatar extends StatelessWidget {
  const HeroAvatar({
    super.key,
    required this.armyKey,
    this.size = 56,
    this.ring = true,
    this.glow = false,
  });
  final String armyKey;
  final double size;
  final bool ring;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final a = ArmyData.get(armyKey);
    final ini = a.hero.split(' ').map((w) => w[0]).take(2).join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: a.gradient,
        boxShadow: [
          if (ring)
            BoxShadow(
              color: a.color.withValues(alpha: 0.5),
              blurRadius: glow ? 18 : 0,
            ),
          BoxShadow(color: TfiTokens.bg1, spreadRadius: ring ? 2 : 0),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              ini,
              style: TfiTokens.display(size * 0.36, color: Colors.white),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: TfiTokens.bg1,
                shape: BoxShape.circle,
                border: Border.all(color: a.color, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(a.emoji, style: TextStyle(fontSize: size * 0.22)),
            ),
          ),
        ],
      ),
    );
  }
}

class CoinChip extends StatelessWidget {
  const CoinChip({super.key, this.value, this.coins, this.large = false});
  final String? value;
  final int? coins;
  final bool large;

  String get _display {
    if (value != null) return value!;
    final n = coins ?? 0;
    if (n >= 1000)
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 9,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TfiTokens.coin.withValues(alpha: 0.15),
            TfiTokens.gold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TfiTokens.coin.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            _display,
            style: TfiTokens.body(
              large ? 14 : 12,
              color: TfiTokens.coin,
              w: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ArmyPtsChip extends StatelessWidget {
  const ArmyPtsChip({super.key, this.value, this.points});
  final String? value;
  final int? points;

  @override
  Widget build(BuildContext context) {
    final v = value ?? '${points ?? 0}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TfiTokens.cyan.withValues(alpha: 0.18),
            TfiTokens.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TfiTokens.cyan.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            '$v pts',
            style: TfiTokens.body(
              12,
              color: TfiTokens.cyan,
              w: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class TfiChip extends StatelessWidget {
  const TfiChip({
    super.key,
    required this.label,
    this.active = false,
    this.color,
    this.icon,
  });
  final String label;
  final bool active;
  final Color? color;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? TfiTokens.fire;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? c.withValues(alpha: 0.13)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? c.withValues(alpha: 0.33) : TfiTokens.line,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TfiTokens.body(
              11.5,
              color: active ? c : TfiTokens.textMid,
              w: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.telugu,
    this.action,
    this.onAction,
  });
  final String title;
  final String? telugu;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TfiTokens.display(22, color: TfiTokens.fire),
                ),
                if (telugu != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    telugu!,
                    style: TfiTokens.telugu(11, color: TfiTokens.textLo),
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                '$action →',
                style: TfiTokens.body(
                  12,
                  color: TfiTokens.fire,
                  w: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.fullWidth = true,
    this.icon,
    this.filled = true,
    this.kind = _BtnKind.fire,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final String? icon;
  final bool filled;
  final _BtnKind kind;

  @override
  Widget build(BuildContext context) {
    final grad = switch (kind) {
      _BtnKind.gold => TfiTokens.gradGold,
      _BtnKind.purple => TfiTokens.gradPurple,
      _ => TfiTokens.gradFire,
    };
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: filled ? grad : null,
          color: filled ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: TfiTokens.lineStrong),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: TfiTokens.fire.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Text(icon!), const SizedBox(width: 8)],
                Text(
                  label,
                  style: TfiTokens.body(
                    15,
                    color: filled ? Colors.white : TfiTokens.textHi,
                    w: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _BtnKind { fire, gold, purple }

class TfiCard extends StatelessWidget {
  const TfiCard({
    super.key,
    required this.child,
    this.padding,
    this.accent,
    this.noPad = false,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accent;
  final bool noPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14172A), Color(0xFF0F1220)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent?.withValues(alpha: 0.4) ?? TfiTokens.line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: noPad ? null : (padding ?? const EdgeInsets.all(14)),
      child: child,
    );
  }
}

class TfiProgressBar extends StatelessWidget {
  const TfiProgressBar({
    super.key,
    required this.value,
    this.max = 1,
    this.color,
    this.height = 6,
  });
  final double value;
  final double max;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);
    final c = color ?? TfiTokens.fire;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.07)),
            FractionallySizedBox(
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrustBadge extends StatelessWidget {
  const TrustBadge({super.key, this.status = 'verified'});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      'official' => ('Official', const Color(0xFF6FE3A0), Color(0x2930C76C)),
      'verified' => ('Verified', const Color(0xFF7DB1FF), Color(0x293E8BFF)),
      'media_report' => (
        'Media Report',
        const Color(0xFFF5C26E),
        Color(0x29F5A524),
      ),
      _ => ('Buzz', const Color(0xFFFF7AAC), Color(0x29E93D82)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TfiTokens.body(9.5, color: fg, w: FontWeight.w700),
      ),
    );
  }
}

class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    this.title,
    this.telugu,
    this.tag,
    this.emoji,
    this.width = 140,
    this.height = 185,
    this.size,
  });
  final String? title;
  final String? telugu;
  final String? tag;
  final String? emoji;
  final double width;
  final double height;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final s = size ?? width;
    if (emoji != null) {
      return Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: TfiTokens.gradFire,
          border: Border.all(color: TfiTokens.line),
        ),
        alignment: Alignment.center,
        child: Text(emoji!, style: TextStyle(fontSize: s * 0.45)),
      );
    }
    final t = title ?? '';
    final hash = t.codeUnits.fold(0, (a, b) => a + b);
    final colors = [
      [
        const Color(0xFFFF7A1A),
        const Color(0xFFE63950),
        const Color(0xFF1B1530),
      ],
      [
        const Color(0xFF8B5CF6),
        const Color(0xFF2563EB),
        const Color(0xFF0B0E1A),
      ],
      [
        const Color(0xFFF59E0B),
        const Color(0xFFDC2626),
        const Color(0xFF1B1530),
      ],
    ][hash % 3];
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      child: Stack(
        children: [
          if (tag != null)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag!,
                  style: TfiTokens.body(
                    9,
                    color: Colors.white,
                    w: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TfiTokens.display(11, color: Colors.white),
                ),
                if (telugu != null)
                  Text(
                    telugu!,
                    style: TfiTokens.telugu(9, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackButtonCircle extends StatelessWidget {
  const BackButtonCircle({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TfiTokens.line),
        ),
        alignment: Alignment.center,
        child: Text('‹', style: TfiTokens.display(20, color: TfiTokens.textHi)),
      ),
    );
  }
}
