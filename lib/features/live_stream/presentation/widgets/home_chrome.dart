import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:iconly/iconly.dart';
/// The "SPORT LIVE" wordmark used in the home app bar — white "SPORT" beside a
/// red "LIVE" tag.
class SportLiveLogo extends StatelessWidget {
  const SportLiveLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'SPORT',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.live,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// A bell icon with an unread-count badge.
class NotificationBell extends StatelessWidget {
  const NotificationBell({required this.count, this.onPressed, super.key});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.notifications_none, color: AppColors.white),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                color: AppColors.live,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One destination in [HomeBottomNav].
class HomeNavItem {
  const HomeNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The app's primary bottom-nav destinations, shared across screens so the bar
/// is identical everywhere. Index 2 (Highlights) is the route currently wired.
 List<HomeNavItem> kMainNavItems = [
  const HomeNavItem(icon: IconlyBroken.home, label: 'Home'),
  const HomeNavItem(icon: IconlyBroken.calendar, label: 'Matches'),
  const HomeNavItem(icon: IconlyBroken.video, label: 'Highlights'),
  const HomeNavItem(icon: IconlyBroken.profile, label: 'Profile'),
];

/// Items are split around the centre FAB: indices 0..1 sit left, 2..3 right.
/// The FAB itself is the Scaffold's [FloatingActionButton] (centre-docked).
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<HomeNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final mid = (items.length / 2).ceil();
    final left = items.take(mid).toList();
    final right = items.skip(mid).toList();

    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          for (var i = 0; i < left.length; i++)
            Expanded(
              child: _NavButton(
                item: left[i],
                selected: currentIndex == i,
                onTap: () => onSelected(i),
              ),
            ),
          const SizedBox(width: 56), // room for the centre FAB notch
          for (var i = 0; i < right.length; i++)
            Expanded(
              child: _NavButton(
                item: right[i],
                selected: currentIndex == mid + i,
                onTap: () => onSelected(mid + i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final HomeNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.info : AppColors.textSecondary;
    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
