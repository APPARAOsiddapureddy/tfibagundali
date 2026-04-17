import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _firePulse;
  late final AnimationController _emberPulse;
  late final AnimationController _raysOpacity;
  late final AnimationController _particleDrive;
  late final AnimationController _titleEnter;
  late final AnimationController _flicker;
  late final AnimationController _hintPulse;
  late final List<_EmberParticle> _particles;

  @override
  void initState() {
    super.initState();
    _firePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _emberPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _raysOpacity = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _particleDrive = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _titleEnter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _flicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..repeat(reverse: true);

    _hintPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    final rnd = math.Random(42);
    _particles = List.generate(28, (i) {
      return _EmberParticle(
        left: rnd.nextDouble(),
        size: 1.5 + rnd.nextDouble() * 3.5,
        durationMs: 2400 + rnd.nextInt(2600),
        delayMs: rnd.nextInt(2200),
        gold: i.isEven,
      );
    });
  }

  @override
  void dispose() {
    _firePulse.dispose();
    _emberPulse.dispose();
    _raysOpacity.dispose();
    _particleDrive.dispose();
    _titleEnter.dispose();
    _flicker.dispose();
    _hintPulse.dispose();
    super.dispose();
  }

  void _onTapEnter() {
    final auth = ref.read(authProvider);
    final loggedIn = auth.accessToken != null && auth.accessToken!.isNotEmpty;
    if (loggedIn) {
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTapEnter,
      child: Scaffold(
        backgroundColor: AppColors.splashBg,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // Fire base + core + tongue (AnimationController only — spec)
            AnimatedBuilder(
              animation: _firePulse,
              builder: (context, _) {
                final t = CurvedAnimation(parent: _firePulse, curve: Curves.easeInOut);
                final scale = 1.0 + (t.value * 0.07);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: -size.width * 0.15,
                      right: -size.width * 0.15,
                      bottom: -size.height * 0.08,
                      height: size.height * 0.55,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0, 0.85),
                              radius: 1.05,
                              colors: [
                                AppColors.fireOrange.withValues(alpha: 0.55),
                                const Color(0xFFE63946).withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.22,
                      right: size.width * 0.22,
                      bottom: -size.height * 0.02,
                      height: size.height * 0.62,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0, 0.92),
                              radius: 0.55,
                              colors: [
                                AppColors.red.withValues(alpha: 0.85),
                                AppColors.red.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.42,
                      right: size.width * 0.42,
                      bottom: size.height * 0.02,
                      height: size.height * 0.45,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0, 0.95),
                              radius: 0.35,
                              colors: [
                                AppColors.gold.withValues(alpha: 0.55),
                                AppColors.red.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Ember bloom (gold glow floating up)
            AnimatedBuilder(
              animation: Listenable.merge([_emberPulse, _particleDrive]),
              builder: (context, _) {
                final y = -18.0 * math.sin(_emberPulse.value * math.pi);
                return Positioned(
                  left: size.width * 0.34,
                  right: size.width * 0.34,
                  bottom: size.height * 0.18 + y,
                  height: size.height * 0.22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.95,
                        colors: [
                          AppColors.gold.withValues(alpha: 0.35),
                          AppColors.gold.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Particles
            ..._particles.map((p) {
              return AnimatedBuilder(
                animation: _particleDrive,
                builder: (context, _) {
                  final t = ((_particleDrive.value * 5000 + p.delayMs) % p.durationMs) /
                      p.durationMs;
                  final dy = -380.0 * Curves.easeOut.transform(t);
                  final opacity = (1.0 - t).clamp(0.0, 1.0);
                  final color = p.gold
                      ? AppColors.gold.withValues(alpha: 0.85 * opacity)
                      : AppColors.fireOrange.withValues(alpha: 0.85 * opacity);
                  return Positioned(
                    left: p.left * (size.width - 12),
                    bottom: 40 + dy,
                    child: IgnorePointer(
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: color.withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Light rays (CustomPainter)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _raysOpacity,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SplashRaysPainter(opacity: 0.25 + (_raysOpacity.value * 0.35)),
                  );
                },
              ),
            ),

            // Vignette
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Title block ~80px from bottom
            Positioned(
              left: 18,
              right: 18,
              bottom: 80 + bottomInset,
              child: AnimatedBuilder(
                animation: Listenable.merge([_titleEnter, _flicker]),
                builder: (context, _) {
                  final enter = CurvedAnimation(
                    parent: _titleEnter,
                    curve: Curves.easeOutCubic,
                  ).value;
                  final flick = 0.92 + (_flicker.value * 0.08);

                  final titleSlide = Tween<double>(begin: 14, end: 0).transform(enter);
                  final titleOpacity = enter;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: titleOpacity,
                        child: Transform.translate(
                          offset: Offset(0, titleSlide),
                          child: Text(
                            'TFI',
                            textAlign: TextAlign.center,
                            style: AppTheme.headingLarge.copyWith(
                              fontSize: 130,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 18 * flick,
                                  color: AppColors.red.withValues(alpha: 0.85),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: titleOpacity,
                        child: Transform.scale(
                          scale: 0.985 + (_emberPulse.value * 0.03),
                          child: Container(
                            height: 3,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.gold, AppColors.red, AppColors.gold],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: titleOpacity,
                        child: Transform.translate(
                          offset: Offset(0, titleSlide),
                          child: Text(
                            'BAGUNDALI',
                            textAlign: TextAlign.center,
                            style: AppTheme.headingLarge.copyWith(
                              fontSize: 56,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  blurRadius: 16 * flick,
                                  color: AppColors.gold.withValues(alpha: 0.75),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // TAP TO ENTER
            Positioned(
              left: 0,
              right: 0,
              bottom: 22 + bottomInset,
              child: AnimatedBuilder(
                animation: _hintPulse,
                builder: (context, _) {
                  final v = 0.35 + (0.65 * _hintPulse.value);
                  return Opacity(
                    opacity: v,
                    child: Text(
                      'TAP TO ENTER',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmberParticle {
  _EmberParticle({
    required this.left,
    required this.size,
    required this.durationMs,
    required this.delayMs,
    required this.gold,
  });

  final double left;
  final double size;
  final int durationMs;
  final int delayMs;
  final bool gold;
}

class _SplashRaysPainter extends CustomPainter {
  _SplashRaysPainter({required this.opacity});

  final double opacity;

  static const _anglesDeg = <double>[
    -66, -48, -32, -18, -7, 0, 7, 18, 32, 48, 66,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height - 6);
    final maxLen = size.height * 0.95;

    for (var i = 0; i < _anglesDeg.length; i++) {
      final deg = _anglesDeg[i];
      final rad = deg * math.pi / 180;
      final dir = Offset(math.sin(rad), -math.cos(rad));
      final end = origin + dir * maxLen;

      final centerish = i >= 4 && i <= 6;
      final c1 = centerish ? AppColors.red : AppColors.gold;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            c1.withValues(alpha: 0.0),
            c1.withValues(alpha: opacity),
            c1.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromPoints(origin, end))
        ..strokeWidth = centerish ? 3.2 : 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(origin, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashRaysPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
