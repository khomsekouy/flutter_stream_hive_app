import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/notifications/notification_manager.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/saved/saved_streams_store.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/content/profile_content.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/favorites/favorite_teams_store.dart';
import 'package:go_router/go_router.dart';

/// The Profile tab: account summary, stats, favourite clubs, recent activity
/// and an account-settings list. Presentation-only (sample content).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _soon(BuildContext context, String label) =>
      NotificationManager.info(context, '$label — coming soon');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(onSettings: () => _soon(context, 'Settings')),
            _ProfileCard(
              profile: kUserProfile,
              stats: kProfileStats,
              onEdit: () => _soon(context, 'Edit profile'),
              onSavedTap: () => context.pushNamed(AppRoute.saved),
              onFavoritesTap: () => context.pushNamed(AppRoute.clubs),
            ),
            SectionHeader(
              title: 'My Favorites',
              onViewAll: () => context.pushNamed(AppRoute.clubs),
            ),
            ListenableBuilder(
              listenable: getIt<FavoriteTeamsStore>(),
              builder: (context, _) => _FavoritesRow(
                teams: getIt<FavoriteTeamsStore>().items,
                onTeam: (t) => context.pushNamed(
                  AppRoute.clubDetail,
                  pathParameters: {'name': t.name},
                  extra: t.country,
                ),
                onAddMore: () => context.pushNamed(AppRoute.clubs),
              ),
            ),
            SectionHeader(
              title: 'Recent Activity',
              onViewAll: () => _soon(context, 'Recent Activity'),
            ),
            ...kRecentActivity.map(
              (a) => _ActivityRow(
                item: a,
                onTap: () => _soon(context, 'Replay'),
                onOptions: () => _soon(context, 'Options'),
              ),
            ),
            const SizedBox(height: 12),
            _MenuList(
              rows: kProfileMenu,
              onTap: (r) => _soon(context, r.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PROFILE',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Manage your account and preferences',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
        child: child,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.stats,
    required this.onEdit,
    required this.onSavedTap,
    required this.onFavoritesTap,
  });

  final UserProfile profile;
  final List<ProfileStat> stats;
  final VoidCallback onEdit;
  final VoidCallback onSavedTap;
  final VoidCallback onFavoritesTap;

  /// Builds a stat tile, binding the Saved/Favorites tiles to their store so
  /// the count stays live and they navigate on tap.
  Widget _statTile(ProfileStat stat) {
    switch (stat.label) {
      case 'Saved':
        return ListenableBuilder(
          listenable: getIt<SavedStreamsStore>(),
          builder: (context, _) => _StatTile(
            stat: stat,
            onTap: onSavedTap,
            valueOverride: '${getIt<SavedStreamsStore>().items.length}',
          ),
        );
      case 'Favorites':
        return ListenableBuilder(
          listenable: getIt<FavoriteTeamsStore>(),
          builder: (context, _) => _StatTile(
            stat: stat,
            onTap: onFavoritesTap,
            valueOverride: '${getIt<FavoriteTeamsStore>().items.length}',
          ),
        );
      default:
        return _StatTile(stat: stat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(url: profile.avatarUrl, onEdit: onEdit),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (profile.isPremium) const _PremiumPill(),
                  ],
                ),
              ),
              _MemberBadge(memberSince: profile.memberSince),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: AppColors.outline.withValues(alpha: 0.5),
            ),
          ),
          Row(
            children: [
              for (final s in stats) Expanded(child: _statTile(s)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.onEdit});

  final String url;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (context, _) => const ColoredBox(
                color: AppColors.surfaceHigh,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              errorWidget: (context, _, _) => const ColoredBox(
                color: AppColors.surfaceHigh,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: const Icon(Icons.edit, size: 12, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumPill extends StatelessWidget {
  const _PremiumPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 14, color: AppColors.info),
          SizedBox(width: 6),
          Text(
            'Premium User',
            style: TextStyle(
              color: AppColors.info,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({required this.memberSince});

  final String memberSince;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Member Since',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        Text(
          memberSince,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Icon(Icons.verified, color: AppColors.info, size: 26),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, this.onTap, this.valueOverride});

  final ProfileStat stat;
  final VoidCallback? onTap;

  /// When set, shown instead of [ProfileStat.value] (e.g. a live count).
  final String? valueOverride;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Icon(stat.icon, color: stat.color, size: 22),
            const SizedBox(height: 6),
            Text(
              valueOverride ?? stat.value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesRow extends StatelessWidget {
  const _FavoritesRow({
    required this.teams,
    required this.onTeam,
    required this.onAddMore,
  });

  final List<FavoriteTeam> teams;
  final ValueChanged<FavoriteTeam> onTeam;
  final VoidCallback onAddMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: teams.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == teams.length) {
            return _AddMoreCard(onTap: onAddMore);
          }
          final team = teams[i];
          return _FavoriteCard(team: team, onTap: () => onTeam(team));
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.team, required this.onTap});

  final FavoriteTeam team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TeamCrest(team: team.name, size: 44),
            const SizedBox(height: 8),
            Text(
              team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              team.country,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMoreCard extends StatelessWidget {
  const _AddMoreCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.info),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.info, size: 28),
            SizedBox(height: 6),
            Text(
              'Add More',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.item,
    required this.onTap,
    required this.onOptions,
  });

  final ActivityItem item;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _ActivityThumb(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WATCHED',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    item.timeAgo,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onOptions,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityThumb extends StatelessWidget {
  const _ActivityThumb({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 96,
        height: 64,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, _) =>
                  const ColoredBox(color: AppColors.surfaceHigh),
              errorWidget: (context, _, _) =>
                  const ColoredBox(color: AppColors.surfaceHigh),
            ),
            const ColoredBox(color: Colors.black26),
            const Center(
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black45,
                child: Icon(Icons.play_arrow, color: AppColors.white, size: 18),
              ),
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.duration,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.rows, required this.onTap});

  final List<ProfileMenuRow> rows;
  final ValueChanged<ProfileMenuRow> onTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _MenuRow(row: rows[i], onTap: () => onTap(rows[i])),
            if (i != rows.length - 1)
              Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: AppColors.outline.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.row, required this.onTap});

  final ProfileMenuRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(row.icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                row.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (row.badge > 0) _Badge(count: row.badge),
            if (row.trailingPill != null) _Pill(text: row.trailingPill!),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      decoration: const BoxDecoration(
        color: AppColors.live,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.info,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
