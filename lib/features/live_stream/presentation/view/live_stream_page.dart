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
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/featured_carousel.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_chrome.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Entry point for the feature.

class LiveStreamPage extends StatelessWidget {
  const LiveStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<LiveStreamCubit>();
        unawaited(cubit.loadLiveStreams());
        return cubit;
      },
      child: const LiveStreamView(),
    );
  }
}

/// The home dashboard: hero carousel, live & upcoming matches, a league
/// filter, highlights and news, under a branded app bar and bottom nav.
class LiveStreamView extends StatefulWidget {
  const LiveStreamView({super.key});

  @override
  State<LiveStreamView> createState() => _LiveStreamViewState();
}

class _LiveStreamViewState extends State<LiveStreamView> {
  int _league = 0;

  bool _matchesLeague(LiveStream s) {
    final competition = kLeagueFilters[_league].competition;
    return competition == null || s.competition == competition;
  }

  void _openDetail(LiveStream stream) => context.pushNamed(
    AppRoute.streamDetail,
    pathParameters: {'id': stream.id},
    extra: stream,
  );

  void _comingSoon(String label) =>
      NotificationManager.info(context, '$label — coming soon');

  @override
  Widget build(BuildContext context) {
    // Bottom nav + Live FAB are owned by the shell (ScaffoldWithNavBar); this
    // screen only provides its app bar and scrollable body.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 16,
        title: const SportLiveLogo(),
        actions: [
          IconButton(
            onPressed: () => _comingSoon('Search'),
            icon: const Icon(Icons.search, color: AppColors.white),
          ),
          NotificationBell(
            count: 3,
            onPressed: () => _comingSoon('Notifications'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<LiveStreamCubit, LiveStreamState>(
        builder: (context, state) {
          switch (state.status) {
            case LiveStreamStatus.initial:
            case LiveStreamStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case LiveStreamStatus.failure:
              return _ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () =>
                    context.read<LiveStreamCubit>().loadLiveStreams(),
              );
            case LiveStreamStatus.success:
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<LiveStreamCubit>().loadLiveStreams(),
                child: _Dashboard(
                  streams: state.streams,
                  league: _league,
                  matchesLeague: _matchesLeague,
                  onLeagueSelected: (i) => setState(() => _league = i),
                  onOpenDetail: _openDetail,
                  onViewAll: _comingSoon,
                  onOpenLive: () => context.pushNamed(AppRoute.live),
                  onOpenHighlights: () =>
                      context.goNamed(AppRoute.highlights),
                ),
              );
          }
        },
      ),
    );
  }
}

/// The scrollable dashboard content.
class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.streams,
    required this.league,
    required this.matchesLeague,
    required this.onLeagueSelected,
    required this.onOpenDetail,
    required this.onViewAll,
    required this.onOpenLive,
    required this.onOpenHighlights,
  });

  final List<LiveStream> streams;
  final int league;
  final bool Function(LiveStream) matchesLeague;
  final ValueChanged<int> onLeagueSelected;
  final ValueChanged<LiveStream> onOpenDetail;
  final ValueChanged<String> onViewAll;
  final VoidCallback onOpenLive;
  final VoidCallback onOpenHighlights;

  static String _formatKickOff(DateTime? start) {
    if (start == null) return 'Time TBD';
    final local = start.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = day.difference(today).inDays;
    final time = DateFormat('h:mm a').format(local);
    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Tomorrow, $time';
    return '${DateFormat('EEE d MMM').format(local)}, $time';
  }

  @override
  Widget build(BuildContext context) {
    final live = streams
        .where((s) => s.isLive && s.hasMatch && matchesLeague(s))
        .toList();
    final upcoming = streams
        .where((s) => s.status == StreamStatus.upcoming && matchesLeague(s))
        .toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        FeaturedCarousel(
          matches: kFeaturedMatches,
          onTap: (_) => onViewAll('Featured match'),
        ),

        // ---- Live Now ----
        SectionHeader(
          title: 'Live Now',
          onViewAll: onOpenLive,
        ),
        if (live.isEmpty)
          const _EmptyRow(text: 'No live matches in this league.')
        else
          ...live.take(4).map(
            (s) => LiveMatchCard(match: s, onTap: () => onOpenDetail(s)),
          ),

        // ---- Upcoming Matches ----
        SectionHeader(
          title: 'Upcoming Matches',
          onViewAll: () => onViewAll('Upcoming Matches'),
        ),
        if (upcoming.isEmpty)
          const _EmptyRow(text: 'No upcoming matches in this league.')
        else
          ...upcoming.map(
            (s) => UpcomingMatchCard(
              match: s,
              kickOff: _formatKickOff(s.startTime),
              onDetails: () => onOpenDetail(s),
            ),
          ),

        // ---- Top Leagues ----
        const SectionHeader(title: 'Top Leagues'),
        LeagueFilterBar(
          filters: kLeagueFilters,
          selected: league,
          onSelected: onLeagueSelected,
        ),

        // ---- Highlights ----
        SectionHeader(
          title: 'Highlights',
          onViewAll: onOpenHighlights,
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kHighlights.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => HighlightCard(
              highlight: kHighlights[i],
              onTap: onOpenHighlights,
            ),
          ),
        ),

        // ---- Latest News ----
        SectionHeader(
          title: 'Latest News',
          onViewAll: () => onViewAll('Latest News'),
        ),
        ...kLatestNews.map(
          (a) => NewsTile(article: a, onTap: () => onViewAll('Article')),
        ),
      ],
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
