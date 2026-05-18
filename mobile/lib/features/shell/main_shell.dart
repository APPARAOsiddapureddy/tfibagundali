import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/tfi_tab_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: navigationShell,
      bottomNavigationBar: TfiTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
