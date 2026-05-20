import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Original TFI tab bar — Home, Quiz, Explore, Polls, Profile.
class TfiTabBar extends StatelessWidget {
  const TfiTabBar({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.quiz_rounded, Icons.quiz_outlined, 'Quiz'),
    (Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
    (Icons.how_to_vote_rounded, Icons.how_to_vote_outlined, 'Polls'),
    (Icons.person_rounded, Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0D14),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final on = i == currentIndex;
              final t = _tabs[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        on ? t.$1 : t.$2,
                        size: 24,
                        color: on ? TfiTokens.gold : Colors.white.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t.$3,
                        style: TfiTokens.body(
                          10,
                          color: on ? TfiTokens.gold : Colors.white.withValues(alpha: 0.35),
                          w: on ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
