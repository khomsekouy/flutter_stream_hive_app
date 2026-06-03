import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/notifications/notification_manager.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_chrome.dart';
import 'package:go_router/go_router.dart';

/// App shell that hosts the persistent bottom nav + central "Live" action and
/// swaps tab content via the [StatefulNavigationShell]'s [IndexedStack].
///
/// Because the shell stays mounted, switching tabs is instant and each tab
/// keeps its scroll position and state — no route transition, no reload.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Branch order matches [kMainNavItems] order (Home, Matches, Highlights,
  /// Profile), so the nav index *is* the branch index.
  void _onTap(int navIndex) {
    navigationShell.goBranch(
      navIndex,
      // Re-tapping the active tab pops it back to its root.
      initialLocation: navIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            NotificationManager.info(context, 'Live — coming soon'),
        backgroundColor: AppColors.live,
        shape: const CircleBorder(),
        child: const Icon(Icons.sensors, color: AppColors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNav(
        items: kMainNavItems,
        currentIndex: navigationShell.currentIndex,
        onSelected: _onTap,
      ),
    );
  }
}
