import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/onboard_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/fan_army/screens/fan_army_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/movies/screens/movie_detail_screen.dart';
import '../../features/premium/screens/premium_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/quiz/screens/quiz_question_screen.dart';
import '../../features/quiz/models/quiz_session_model.dart';
import '../../features/quiz/screens/quiz_results_screen.dart';
import '../../features/quiz/screens/quiz_start_screen.dart';
import '../../features/share_zone/screens/share_zone_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isLoggingIn = loc == '/auth';
      final isOnboarding = loc == '/onboard';
      final isSplash = loc == '/';

      if (auth.isLoading && isSplash) return null;

      final isLoggedIn = auth.accessToken != null && auth.accessToken!.isNotEmpty;

      if (!isLoggedIn) {
        if (isLoggingIn) return null;
        if (isSplash) return null;
        return '/auth';
      }

      // New users must finish onboarding before shell routes.
      if (auth.user?.isNewUser == true) {
        if (!isOnboarding) return '/onboard';
        return null;
      }

      // Logged-in user on auth/splash → home.
      if (isLoggingIn || isSplash) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/home/share',
            builder: (context, state) => const ShareZoneScreen(),
          ),
          GoRoute(
            path: '/home/army',
            builder: (context, state) => const FanArmyScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home/quiz',
        builder: (context, state) => const QuizStartScreen(),
      ),
      GoRoute(
        path: '/home/quiz/play',
        builder: (context, state) => const QuizQuestionScreen(),
      ),
      GoRoute(
        path: '/home/quiz/results',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is QuizResultsSummary) {
            return QuizResultsScreen(summary: extra);
          }
          return const QuizResultsScreen();
        },
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) =>
            MovieDetailScreen(movieId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    _sub = ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}