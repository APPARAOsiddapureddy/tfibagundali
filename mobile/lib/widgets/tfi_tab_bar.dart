import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

class TfiTabBar extends StatelessWidget {
  const TfiTabBar({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const tabs = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.quiz_outlined, Icons.quiz, 'Quiz'),
    (Icons.share_outlined, Icons.share, 'Share'),
    (Icons.shield_outlined, Icons.shield, 'Army'),
    (Icons.person_outline, Icons.person, 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TfiTokens.bg1.withValues(alpha: 0), TfiTokens.bg1.withValues(alpha: 0.98)],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141622).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: TfiTokens.line),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final on = i == currentIndex;
            final t = tabs[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: on
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [TfiTokens.fire.withValues(alpha: 0.18), TfiTokens.fireDeep.withValues(alpha: 0.08)],
                          ),
                          border: Border.all(color: TfiTokens.fire.withValues(alpha: 0.35)),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(on ? t.$2 : t.$1, size: 22, color: on ? TfiTokens.fire : TfiTokens.textFaint),
                      const SizedBox(height: 3),
                      Text(t.$3, style: TfiTokens.body(10.5, color: on ? TfiTokens.fire : TfiTokens.textFaint, w: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
