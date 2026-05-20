import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/poster_wall.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070D),
      body: Stack(
        children: [
          // ── Poster wall background ──
          const PosterWall(tint: 0.55),

          // ── Centered brand content ──
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── "NOW SHOWING · DAILY" chip ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TfiTokens.goldGlow.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: TfiTokens.goldGlow.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TfiTokens.goldHot,
                              boxShadow: [BoxShadow(color: TfiTokens.goldHot, blurRadius: 10)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'NOW SHOWING · DAILY',
                            style: TfiTokens.body(11, color: TfiTokens.goldWarm, w: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ── Brandmark: Icon + Title ──
                    _buildBrandIcon(76, 22),
                    const SizedBox(height: 18),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFFFB36C)],
                      ).createShader(bounds),
                      child: Text(
                        'TFI Bagundali',
                        style: TfiTokens.display(44, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Tagline pill ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        'Mana Cinema · Mana Updates · Mana Pride',
                        style: TfiTokens.body(13, color: Colors.white.withValues(alpha: 0.92), w: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom strip ──
          Positioned(
            bottom: 60,
            left: 22,
            right: 22,
            child: Column(
              children: [
                // Ticker row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141628).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      // Overlapping colored dots
                      SizedBox(
                        width: 22 + 14 + 14.0, // 3 dots with overlap
                        height: 22,
                        child: Stack(
                          children: [
                            _colorDot(0, const Color(0xFFFFB52E)),
                            _colorDot(14, const Color(0xFFE5484D)),
                            _colorDot(28, const Color(0xFF8B5CF6)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TfiTokens.body(11.5, color: Colors.white.withValues(alpha: 0.75)),
                            children: [
                              TextSpan(text: '12 fresh updates', style: TfiTokens.body(11.5, color: Colors.white, w: FontWeight.w800)),
                              const TextSpan(text: ' in TFI today'),
                            ],
                          ),
                        ),
                      ),
                      // Pulsing dots
                      Row(
                        children: List.generate(3, (i) => Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: _PulsingDot(delay: i * 200),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '● POWERED BY FANS',
                  style: TfiTokens.body(10, color: Colors.white.withValues(alpha: 0.35), w: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gradient app icon (clapperboard-style)
  static Widget _buildBrandIcon(double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.6),
          end: Alignment(0.8, 0.8),
          colors: [Color(0xFFFFB52E), Color(0xFFE5484D), Color(0xFF8B5CF6)],
          stops: [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: TfiTokens.goldGlow.withValues(alpha: 0.45), blurRadius: 60, offset: const Offset(0, 18)),
          const BoxShadow(color: Colors.white10, blurRadius: 0, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.55, size * 0.55),
        painter: _ClapperboardPainter(),
      ),
    );
  }

  static Widget _colorDot(double left, Color color) {
    return Positioned(
      left: left,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: TfiTokens.bg1, width: 2),
        ),
      ),
    );
  }
}

/// Custom painter for the clapperboard/film icon inside the brand icon.
class _ClapperboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Main rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, w * 0.12, w * 0.9, h * 0.76),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);

    // Corner dots
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    const dotR = 1.5;
    canvas.drawCircle(Offset(w * 0.15, h * 0.24), dotR, dotPaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.24), dotR, dotPaint);
    canvas.drawCircle(Offset(w * 0.15, h * 0.78), dotR, dotPaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.78), dotR, dotPaint);

    // Text lines
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.3, h * 0.38), Offset(w * 0.7, h * 0.38), linePaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.52), Offset(w * 0.62, h * 0.52), linePaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.66), Offset(w * 0.54, h * 0.66), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated pulsing dot (for the bottom ticker).
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({this.delay = 0});
  final int delay;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
    ]).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: _opacity.value),
        ),
      ),
    );
  }
}
