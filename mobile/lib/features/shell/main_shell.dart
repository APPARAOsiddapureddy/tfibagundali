import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/tfi_responsive.dart';
import '../../widgets/tfi_tab_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tabBar = TfiTabBar(
      currentIndex: navigationShell.currentIndex,
      onTap: navigationShell.goBranch,
    );

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: TfiTokens.bg0,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TfiResponsive.webFrameMaxWidth),
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: TfiTokens.gradCinematicBg),
              child: Column(
                children: [
                  Expanded(child: navigationShell),
                  tabBar,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: navigationShell,
      bottomNavigationBar: tabBar,
    );
  }
}
