import 'package:flutter_stream_hive_app/features/live_stream/live_stream.dart';
import 'package:flutter_stream_hive_app/features/splash/splash.dart';
import 'package:go_router/go_router.dart';

/// Named-route identifiers, so navigation is `pushNamed(AppRoute.streamDetail)`
/// instead of stringly-typed paths sprinkled across widgets.
abstract final class AppRoute {
  const AppRoute._();

  static const String splash = 'splash';
  static const String home = 'home';
  static const String streamDetail = 'streamDetail';
}

/// The single, declarative source of truth for navigation.
///
/// Routes are URL-based (`/`, `/stream/:id`) so the app is deep-linkable and
/// the back stack is real browser/Android history. Screens stay navigation-
/// agnostic — they call `context.pushNamed(...)` and never construct a
/// `MaterialPageRoute` themselves.
abstract final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/',
        name: AppRoute.home,
        builder: (context, state) => const LiveStreamPage(),
        routes: [
          GoRoute(
            // Full path: /stream/:id
            path: 'stream/:id',
            name: AppRoute.streamDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              // Fast path: the list passes the loaded entity as `extra`.
              // Deep link: `extra` is null, so the screen fetches by id.
              final initial = state.extra as LiveStream?;
              return StreamDetailPage(streamId: id, initialStream: initial);
            },
          ),
        ],
      ),
    ],
  );
}
