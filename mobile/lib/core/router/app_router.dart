import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboard_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/profile_form_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/explore/status_card_detail_screen.dart';
import '../../features/explore/wallpaper_detail_screen.dart';
import '../../features/heroes/hero_detail_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/notifications/notifications_tab_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/movies/movie_detail_screen.dart';
import '../../features/reviews/movie_reviews_screen.dart';
import '../../features/reviews/movie_review_detail_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/polls/poll_detail_screen.dart';
import '../../features/polls/polls_screen.dart';
import '../../features/profile/downloads_screen.dart';
import '../../features/profile/favourite_hero_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/quiz_history_screen.dart';
import '../../features/profile/reminders_screen.dart';
import '../../features/profile/saved_screen.dart';
import '../../features/quiz/quiz_play_screen.dart';
import '../../features/quiz/quiz_result_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/notification_prefs_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/updates/update_detail_screen.dart';
import '../../features/updates/updates_feed_screen.dart';
import '../providers/auth_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // Backend bypassed — no auth-based redirects for now
      // All routes are public for frontend testing
      if (loc == '/splash') return '/login'; // skip splash, go straight to login
      return null;

      // --- Backend auth redirects (commented out for now) ---
      // if (auth.booting) return loc == '/splash' ? null : '/splash';
      // if (loc == '/splash') return auth.isLoggedIn ? '/home' : '/login';
      // final public = {'/login', '/otp', '/onboard', '/onboarding/hero'};
      // if (!auth.isLoggedIn && !public.contains(loc)) return '/login';
      // if (auth.isLoggedIn && (loc == '/login' || loc == '/otp')) return '/home';
      // return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String? ?? '+91'),
      ),
      GoRoute(path: '/onboard', builder: (_, _) => const OnboardScreen()),
      GoRoute(path: '/onboarding/hero', builder: (_, _) => const OnboardScreen()),
      GoRoute(
        path: '/onboarding/profile',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ProfileFormScreen(
            heroKey: data['heroKey'] as String?,
            heroName: data['heroName'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/updates',
        builder: (_, state) => UpdatesFeedScreen(
          initialCategory: state.uri.queryParameters['category'],
          initialHeroId: state.uri.queryParameters['hero_id'],
        ),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/updates/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => UpdateDetailScreen(updateId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/polls/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => PollDetailScreen(pollId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/movies/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => MovieDetailScreen(movieId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/reviews',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const MovieReviewsScreen(),
      ),
      GoRoute(
        path: '/reviews/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => MovieReviewDetailScreen(movieId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/heroes/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => HeroDetailScreen(heroId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/wallpapers/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => WallpaperDetailScreen(wallpaperId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/status-cards/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => StatusCardDetailScreen(cardId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/notification-preferences',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const NotificationPrefsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const NotificationPrefsScreen(),
      ),
      GoRoute(
        path: '/profile/downloads',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const DownloadsScreen(),
      ),
      GoRoute(
        path: '/profile/saved',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SavedScreen(),
      ),
      GoRoute(
        path: '/profile/reminders',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/favourite-hero',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const FavouriteHeroScreen(),
      ),
      GoRoute(
        path: '/profile/quiz-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const QuizHistoryScreen(),
      ),
      GoRoute(
        path: '/quiz/play',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => QuizPlayScreen(session: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/quiz/result',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => QuizResultScreen(result: state.extra as Map<String, dynamic>?),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, state) {
            final data = state.extra as Map<String, dynamic>?;
            return const HomeScreen();
          })]),
          StatefulShellBranch(routes: [GoRoute(path: '/quiz', builder: (_, _) => const QuizScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/polls', builder: (_, _) => const PollsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
        ],
      ),
    ],
  );
}
