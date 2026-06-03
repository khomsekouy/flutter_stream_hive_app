import 'package:flutter/widgets.dart';
import 'package:flutter_stream_hive_app/core/navigation/scaffold_with_nav_bar.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/highlight_list.dart';
import 'package:flutter_stream_hive_app/features/live_stream/live_stream.dart';
import 'package:flutter_stream_hive_app/features/matches/matches.dart';
import 'package:flutter_stream_hive_app/features/onboarding/onboarding.dart';
import 'package:flutter_stream_hive_app/features/profile/profile.dart';
import 'package:flutter_stream_hive_app/features/splash/splash.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoute {
  const AppRoute._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String live = 'live';
  static const String matches = 'matches';
  static const String streamDetail = 'streamDetail';
  static const String highlights = 'highlights';
  static const String profile = 'profile';
}

abstract final class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: AppRoute.home,
                builder: (context, state) => const LiveStreamPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matches',
                name: AppRoute.matches,
                builder: (context, state) => const MatchesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/highlights',
                name: AppRoute.highlights,
                builder: (context, state) => const HighlightListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen Live list: opened from the central Live action in the
      // bottom nav. Pushed on the root navigator so it covers the shell.
      GoRoute(
        path: '/live',
        name: AppRoute.live,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const LiveNowPage(),
      ),
      // Full-screen detail: pushed on the root navigator so it covers the
      // shell (no bottom nav) and Back returns to the active tab.
      GoRoute(
        path: '/stream/:id',
        name: AppRoute.streamDetail,
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final initial = state.extra as LiveStream?;
          return StreamDetailPage(streamId: id, initialStream: initial);
        },
      ),
    ],
  );
}
