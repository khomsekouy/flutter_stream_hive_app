import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/notifications/notification_manager.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/entities/highlight_list.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/presentation/cubit/highlight_list_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';

class HighlightListPage extends StatelessWidget {
  const HighlightListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<HighlightListCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const HighlightListView(),
    );
  }
}

class HighlightListView extends StatefulWidget {
  const HighlightListView({super.key});

  @override
  State<HighlightListView> createState() => _HighlightListViewState();
}

class _HighlightListViewState extends State<HighlightListView> {
  /// Filter chips, in display order. Null league = "All".
  static const List<(String, String?)> _filters = [
    ('All', null),
    ('Champions League', 'Champions League'),
    ('Premier League', 'Premier League'),
    ('La Liga', 'La Liga'),
    ('More', '__more__'),
  ];

  int _filter = 0;

  void _comingSoon(String label) =>
      NotificationManager.info(context, '$label — coming soon');

  List<HighlightList> _applyFilter(List<HighlightList> items) {
    final league = _filters[_filter].$2;
    if (league == null || league == '__more__') return items;
    return items.where((h) => h.league == league).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Bottom nav + Live FAB are owned by the shell (ScaffoldWithNavBar).
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onComingSoon: _comingSoon),
            _FilterChips(
              filters: _filters,
              selected: _filter,
              onSelected: (i) {
                if (_filters[i].$2 == '__more__') {
                  _comingSoon('More leagues');
                  return;
                }
                setState(() => _filter = i);
              },
            ),
            Expanded(
              child: BlocBuilder<HighlightListCubit, HighlightListState>(
                builder: (context, state) {
                  switch (state.status) {
                    case HighlightListStatus.initial:
                    case HighlightListStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case HighlightListStatus.failure:
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    case HighlightListStatus.success:
                      final items = _applyFilter(state.items);
                      return _HighlightsList(
                        items: items,
                        onTap: (_) => _comingSoon('Video player'),
                        onOptions: (_) => _comingSoon('Options'),
                        onSort: () => _comingSoon('Sort'),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Title block: back button, "Highlights" + subtitle with an accent bar, and
/// search / filter actions.
class _Header extends StatelessWidget {
  const _Header({required this.onComingSoon});

  final ValueChanged<String> onComingSoon;

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
                  'Highlights',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Relive the best moments',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _SquareButton(
            icon: Icons.search,
            onTap: () => onComingSoon('Search'),
          ),
          const SizedBox(width: 10),
          _SquareButton(
            icon: Icons.filter_list,
            onTap: () => onComingSoon('Filter'),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<(String, String?)> filters;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isActive = i == selected;
          final isMore = filters[i].$2 == '__more__';
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.info, AppColors.primary],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.transparent : AppColors.outline,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    filters[i].$1,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isMore)
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HighlightsList extends StatelessWidget {
  const _HighlightsList({
    required this.items,
    required this.onTap,
    required this.onOptions,
    required this.onSort,
  });

  final List<HighlightList> items;
  final ValueChanged<HighlightList> onTap;
  final ValueChanged<HighlightList> onOptions;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SortRow(count: items.length, onSort: onSort);
        }
        final item = items[index - 1];
        return _HighlightCard(
          item: item,
          onTap: () => onTap(item),
          onOptions: () => onOptions(item),
        );
      },
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({required this.count, required this.onSort});

  final int count;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Text(
            'Latest Highlights',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.circle, size: 6, color: AppColors.live),
          const SizedBox(width: 8),
          Text(
            '$count Videos',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSort,
            child: const Row(
              children: [
                Text(
                  'Sort: Latest',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.item,
    required this.onTap,
    required this.onOptions,
  });

  final HighlightList item;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 150, child: _Thumbnail(item: item)),
                Expanded(child: _Details(item: item, onOptions: onOptions)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});

  final HighlightList item;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            radius: 20,
            backgroundColor: Colors.black45,
            child: Icon(Icons.play_arrow, color: AppColors.white, size: 26),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              item.duration,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (item.isHot)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.live,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 12,
                    color: AppColors.white,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'HOT',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.item, required this.onOptions});

  final HighlightList item;
  final VoidCallback onOptions;

  static Color _leagueColor(String league) {
    switch (league) {
      case 'Champions League':
        return AppColors.primaryLight;
      case 'Premier League':
        return AppColors.info;
      case 'La Liga':
        return AppColors.success;
      case 'Serie A':
        return AppColors.warning;
      case 'Bundesliga':
        return AppColors.live;
      default:
        return AppColors.textSecondary;
    }
  }

  static String _formatViews(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M views';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K views';
    return '$v views';
  }

  @override
  Widget build(BuildContext context) {
    final color = _leagueColor(item.league);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LeagueTag(label: item.league, color: color)),
              GestureDetector(
                onTap: onOptions,
                child: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TeamCrest(team: item.homeTeam, size: 28),
              const SizedBox(width: 10),
              Text(
                '${item.homeScore} - ${item.awayScore}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              TeamCrest(team: item.awayTeam, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                item.timeAgo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '•',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const Icon(
                Icons.visibility_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _formatViews(item.views),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeagueTag extends StatelessWidget {
  const _LeagueTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color),
        ),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
