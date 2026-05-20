import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Tilted 3-column movie poster grid background.
/// Translates the PosterWall JSX component from auth.jsx.
class PosterWall extends StatelessWidget {
  const PosterWall({super.key, this.tint = 0.6});

  /// Controls how dark the overlay wash is (0.0–1.0).
  final double tint;

  // Movie poster gradient palettes
  static const _palettes = [
    [Color(0xFFFF7A1A), Color(0xFFE63950), Color(0xFF1B1530)],
    [Color(0xFF8B5CF6), Color(0xFF2563EB), Color(0xFF0B0E1A)],
    [Color(0xFFF59E0B), Color(0xFFDC2626), Color(0xFF1B1530)],
    [Color(0xFFE63950), Color(0xFF8B5CF6), Color(0xFF0B0E1A)],
    [Color(0xFFFFB347), Color(0xFFFF7A1A), Color(0xFF1A0F00)],
    [Color(0xFF2563EB), Color(0xFF8B5CF6), Color(0xFF1B1530)],
    [Color(0xFFDC2626), Color(0xFFF59E0B), Color(0xFF1A0F00)],
  ];

  // 3 columns of posters, each column has 4–5 items
  static const _columns = [
    [0, 1, 2, 3],
    [4, 5, 6, 0, 1],
    [2, 3, 4, 5],
  ];

  // Y offsets for each column (like translateY in JSX)
  static const _columnOffsets = [0.0, -60.0, -30.0];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: [
            // ── Tilted poster grid ──
            Positioned(
              top: -80,
              left: -60,
              right: -60,
              bottom: -80,
              child: Transform.rotate(
                angle: -14 * pi / 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (ci) {
                    return Expanded(
                      child: Transform.translate(
                        offset: Offset(0, _columnOffsets[ci]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Column(
                            children: _columns[ci].map((pi) {
                              final colors = _palettes[pi % _palettes.length];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: AspectRatio(
                                  aspectRatio: 2 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: colors,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Dark wash gradient ──
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(6, 7, 13, tint + 0.2),
                      Color.fromRGBO(6, 7, 13, tint),
                      Color.fromRGBO(6, 7, 13, tint + 0.25),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // ── Warm golden spotlight from above ──
            Positioned(
              top: -120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        TfiTokens.goldGlow.withValues(alpha: 0.32),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
