import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/notifications/notification_manager.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/content/home_content.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/live_stream_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The Matches tab: a "match day" view over all fixtures, grouped by status
/// (Live → Upcoming → Finished). Reuses the live_stream fixtures (single source
/// of truth) rather than a separate matches model.
class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<LiveStreamCubit>();
        unawaited(cubit.loadLiveStreams());
        return cubit;
      },
      child: const MatchesView(),
    );
  }
}

class MatchesView extends StatefulWidget {
  const MatchesView({super.key});

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> {
  int _league = 0;
  int _day = 1; // index into the date strip; defaults to "today".

  bool _matchesLeague(LiveStream s) {
    final competition = kLeagueFilters[_league].competition;
    return competition == null || s.competition == competition;
  }

  void _openDetail(LiveStream s) => context.pushNamed(
    AppRoute.matchDetail,
    pathParameters: {'id': s.id},
    extra: s,
  );

  void _soon(String label) =>
      NotificationManager.info(context, '$label — coming soon');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onCalendar: () => _soon('Calendar')),
            _DateStrip(
              selected: _day,
              onSelected: (i) => setState(() => _day = i),
            ),
            const SizedBox(height: 8),
            LeagueFilterBar(
              filters: kLeagueFilters,
              selected: _league,
              onSelected: (i) => setState(() => _league = i),
            ),
            Expanded(
              child: BlocBuilder<LiveStreamCubit, LiveStreamState>(
                builder: (context, state) {
                  switch (state.status) {
                    case LiveStreamStatus.initial:
                    case LiveStreamStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case LiveStreamStatus.failure:
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    case LiveStreamStatus.success:
                      final fixtures = state.streams
                          .where((s) => s.hasMatch && _matchesLeague(s))
                          .toList();
                      return _FixtureGroups(
                        fixtures: fixtures,
                        onOpen: _openDetail,
                        onAction: _soon,
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

class _Header extends StatelessWidget {
  const _Header({required this.onCalendar});

  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                  'MATCHES',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Browse the fixtures',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCalendar,
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal day selector. Visual for now (highlights the chosen day);
/// hook it up to date-based filtering when the fixtures span more days.
class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // A week starting yesterday, so "today" sits at index 1.
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 1),
    );
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          final isToday = i == 1;
          final isActive = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.info, AppColors.primary],
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? Colors.transparent : AppColors.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'TODAY' : DateFormat('EEE').format(day),
                    style: TextStyle(
                      color: isActive
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isActive
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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

class _FixtureGroups extends StatelessWidget {
  const _FixtureGroups({
    required this.fixtures,
    required this.onOpen,
    required this.onAction,
  });

  final List<LiveStream> fixtures;
  final ValueChanged<LiveStream> onOpen;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final live = fixtures.where((s) => s.status == StreamStatus.live).toList();
    final upcoming = fixtures
        .where((s) => s.status == StreamStatus.upcoming)
        .toList();
    final finished = fixtures
        .where((s) => s.status == StreamStatus.ended)
        .toList();

    if (fixtures.isEmpty) {
      return const Center(
        child: Text(
          'No fixtures for this filter.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    Widget cardOf(LiveStream s) => MatchDayCard(
      match: s,
      onTap: () => onOpen(s),
      onAction: onAction,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (live.isNotEmpty) ...[
          const _GroupLabel(
            label: 'LIVE NOW',
            color: AppColors.live,
            icon: Icons.circle,
          ),
          ...live.map(cardOf),
        ],
        if (upcoming.isNotEmpty) ...[
          const _GroupLabel(
            label: 'UPCOMING',
            color: AppColors.info,
            icon: Icons.schedule,
          ),
          ...upcoming.map(cardOf),
        ],
        if (finished.isNotEmpty) ...[
          const _GroupLabel(
            label: 'FINISHED',
            color: AppColors.textSecondary,
            icon: Icons.check_circle_outline,
          ),
          ...finished.map(cardOf),
        ],
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 0, 10),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// The detailed match-day card. The status drives the chip, the centre value
/// (score vs "VS"), and the footer action (Watch / Remind / Highlights).
class MatchDayCard extends StatelessWidget {
  const MatchDayCard({
    required this.match,
    required this.onTap,
    required this.onAction,
    super.key,
  });

  final LiveStream match;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (match.competition ?? match.sport).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _StatusChip(match: match),
                ],
              ),
              const SizedBox(height: 10),
              _TeamRow(team: match.homeTeam),
              _CentreValue(match: match),
              _TeamRow(team: match.awayTeam),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.stadium_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      match.venue ?? 'Venue TBD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _FooterAction(match: match, onAction: onAction),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team});

  final String? team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          TeamCrest(team: team, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              team ?? 'TBD',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CentreValue extends StatelessWidget {
  const _CentreValue({required this.match});

  final LiveStream match;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            match.hasScore ? '${match.homeScore} - ${match.awayScore}' : 'VS',
            style: TextStyle(
              color: match.hasScore
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: match.hasScore ? 22 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (match.minute != null) ...[
            const SizedBox(width: 10),
            Text(
              "${match.minute}'",
              style: const TextStyle(
                color: AppColors.live,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.match});

  final LiveStream match;

  @override
  Widget build(BuildContext context) {
    switch (match.status) {
      case StreamStatus.live:
        return const _Chip(
          color: AppColors.live,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 7, color: AppColors.white),
              SizedBox(width: 5),
              Text(
                'LIVE',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      case StreamStatus.upcoming:
        final time = match.startTime == null
            ? 'Soon'
            : DateFormat('h:mm a').format(match.startTime!.toLocal());
        return _Chip(
          color: AppColors.info,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 12, color: AppColors.info),
              const SizedBox(width: 5),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.info,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case StreamStatus.ended:
        return const _Chip(
          color: AppColors.textSecondary,
          child: Text(
            'FT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.child, this.filled = false});

  final Color color;
  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: filled ? null : Border.all(color: color),
      ),
      child: child,
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.match, required this.onAction});

  final LiveStream match;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (match.status) {
      StreamStatus.live => ('Watch', Icons.play_arrow),
      StreamStatus.upcoming => ('Remind', Icons.notifications_none),
      StreamStatus.ended => ('Highlights', Icons.ondemand_video_outlined),
    };
    return GestureDetector(
      onTap: () => onAction(label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.info,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
