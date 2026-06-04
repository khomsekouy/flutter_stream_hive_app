import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/live_stream_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Full-screen list of every upcoming fixture, sorted by kick-off and split
/// into day groups (Today / Tomorrow / date). Reuses [LiveStreamCubit] as the
/// single source of truth, mirroring `LiveNowPage`.
class UpcomingPage extends StatelessWidget {
  const UpcomingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<LiveStreamCubit>();
        unawaited(cubit.loadLiveStreams());
        return cubit;
      },
      child: const UpcomingView(),
    );
  }
}

class UpcomingView extends StatelessWidget {
  const UpcomingView({super.key});

  void _openDetail(BuildContext context, LiveStream stream) =>
      context.pushNamed(
        AppRoute.matchDetail,
        pathParameters: {'id': stream.id},
        extra: stream,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Upcoming Matches',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<LiveStreamCubit, LiveStreamState>(
        builder: (context, state) {
          switch (state.status) {
            case LiveStreamStatus.initial:
            case LiveStreamStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case LiveStreamStatus.failure:
              return _CenteredMessage(
                text: state.errorMessage ?? 'Something went wrong.',
                onRetry: () =>
                    context.read<LiveStreamCubit>().loadLiveStreams(),
              );
            case LiveStreamStatus.success:
              final groups = _groupByDay(state.streams);
              if (groups.isEmpty) {
                return const _CenteredMessage(
                  text: 'No upcoming matches scheduled.',
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<LiveStreamCubit>().loadLiveStreams(),
                child: ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  children: [
                    for (final group in groups) ...[
                      _DayHeader(label: group.label),
                      for (final match in group.matches)
                        UpcomingMatchCard(
                          match: match,
                          kickOff: _formatKickOff(match.startTime),
                          onDetails: () => _openDetail(context, match),
                        ),
                    ],
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

/// Upcoming fixtures sorted by kick-off (undated last) and bucketed into
/// consecutive day groups for headers.
List<_DayGroup> _groupByDay(List<LiveStream> streams) {
  final upcoming =
      streams.where((s) => s.status == StreamStatus.upcoming).toList()..sort((
        a,
        b,
      ) {
        final at = a.startTime;
        final bt = b.startTime;
        if (at == null && bt == null) return 0;
        if (at == null) return 1; // undated fixtures sink to the bottom
        if (bt == null) return -1;
        return at.compareTo(bt);
      });

  final groups = <_DayGroup>[];
  for (final match in upcoming) {
    final label = _dayLabel(match.startTime);
    if (groups.isNotEmpty && groups.last.label == label) {
      groups.last.matches.add(match);
    } else {
      groups.add(_DayGroup(label: label, matches: [match]));
    }
  }
  return groups;
}

/// "TODAY" / "TOMORROW" / "WED, JUN 10" / "DATE TBD" for a day header.
String _dayLabel(DateTime? start) {
  if (start == null) return 'DATE TBD';
  final local = start.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'TODAY';
  if (diff == 1) return 'TOMORROW';
  return DateFormat('EEE, MMM d').format(local).toUpperCase();
}

/// "Today, 8:00 PM" style kick-off line shown on each card.
String _formatKickOff(DateTime? start) {
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

class _DayGroup {
  _DayGroup({required this.label, required this.matches});

  final String label;
  final List<LiveStream> matches;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 13, color: AppColors.info),
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

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
