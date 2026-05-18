import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/army/army_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboard_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/missions/missions_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/quiz/quiz_play_screen.dart';
import '../../features/quiz/quiz_result_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/share/share_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../providers/auth_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (auth.booting) return loc == '/splash' ? null : '/splash';
      if (loc == '/splash') return auth.isLoggedIn ? '/home' : '/login';
      final public = {'/login', '/otp', '/onboard'};
      if (!auth.isLoggedIn && !public.contains(loc)) return '/login';
      if (auth.isLoggedIn && loc == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String? ?? '+91'),
      ),
      GoRoute(path: '/onboard', builder: (_, __) => const OnboardScreen()),
      GoRoute(
        path: '/missions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const MissionsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/quiz/play',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const QuizPlayScreen(),
      ),
      GoRoute(
        path: '/quiz/result',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const QuizResultScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/share', builder: (_, __) => const ShareScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/army', builder: (_, __) => const ArmyScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
        ],
      ),
    ],
  );
}
