import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_TabSpec>[
    _TabSpec(label: 'Home', icon: '🏠', location: '/home'),
    _TabSpec(label: 'Quiz', icon: '🎯', location: '/home/quiz', isQuizFlow: true),
    _TabSpec(label: 'Share', icon: '📲', location: '/home/share'),
    _TabSpec(label: 'Fan Army', icon: '⚔️', location: '/home/army'),
    _TabSpec(label: 'Profile', icon: '👤', location: '/home/profile'),
  ];

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home/share')) return 2;
    if (loc.startsWith('/home/army')) return 3;
    if (loc.startsWith('/home/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: idx,
        onTap: (i) {
          final tab = _tabs[i];
          if (tab.isQuizFlow) {
            context.push(tab.location);
          } else {
            context.go(tab.location);
          }
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final height = AppTheme.bottomNavHeight + bottomPad;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: height,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.95),
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: List.generate(BottomNavShell._tabs.length, (i) {
              final tab = BottomNavShell._tabs[i];
              final active = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tab.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: AppTheme.bodySmall.copyWith(
                            color: active ? AppColors.red : AppColors.textMuted2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: active ? AppColors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
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

class _TabSpec {
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.location,
    this.isQuizFlow = false,
  });

  final String label;
  final String icon;
  final String location;
  final bool isQuizFlow;
}

