import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/match_score_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/stream_detail_cubit.dart';

/// Detail / watch screen for a single stream, reached via `/stream/:id`.
///
/// [StreamDetailCubit] resolves the stream: instantly from [initialStream] when
/// navigated from the list, or fetched by [streamId] on a cold deep link. Once
/// resolved, [_StreamDetailContent] renders the player + live score.
class StreamDetailPage extends StatelessWidget {
  const StreamDetailPage({
    required this.streamId,
    this.initialStream,
    super.key,
  });

  final String streamId;
  final LiveStream? initialStream;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<StreamDetailCubit>(
          param1: streamId,
          param2: initialStream,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const StreamDetailView(),
    );
  }
}

class StreamDetailView extends StatelessWidget {
  const StreamDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreamDetailCubit, StreamDetailState>(
      builder: (context, state) {
        final stream = state.stream;
        return Scaffold(
          appBar: AppBar(title: Text(stream?.title ?? 'Stream')),
          body: switch (state.status) {
            StreamDetailStatus.initial ||
            StreamDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            StreamDetailStatus.failure => Center(
              child: Text(state.errorMessage ?? 'Could not load this stream.'),
            ),
            StreamDetailStatus.success => _StreamDetailContent(stream: stream!),
          },
        );
      },
    );
  }
}

class _StreamDetailContent extends StatelessWidget {
  const _StreamDetailContent({required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _PlayerPlaceholder(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stream.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                stream.competition ?? stream.sport,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (stream.hasMatch)
                BlocProvider(
                  create: (_) =>
                      getIt<MatchScoreCubit>(param1: stream.id)..start(),
                  child: _LiveScore(stream: stream),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerPlaceholder extends StatelessWidget {
  const _PlayerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 64, color: Colors.white70),
              SizedBox(height: 8),
              Text(
                'Player goes here (HLS via media_kit / video_player)',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live score widget — rebuilds on every frame pushed by [MatchScoreCubit].
class _LiveScore extends StatelessWidget {
  const _LiveScore({required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MatchScoreCubit, MatchScoreState>(
      builder: (context, state) {
        final score = state.score;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live score', style: theme.textTheme.labelLarge),
                    if (score != null)
                      Text(
                        "${score.minute}'",
                        style: theme.textTheme.labelLarge,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TeamScore(
                      team: stream.homeTeam ?? 'Home',
                      score: score?.homeScore,
                    ),
                    Text(':', style: theme.textTheme.headlineMedium),
                    _TeamScore(
                      team: stream.awayTeam ?? 'Away',
                      score: score?.awayScore,
                    ),
                  ],
                ),
                if (state.status == MatchScoreStatus.watching && score == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Connecting to live score…'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TeamScore extends StatelessWidget {
  const _TeamScore({required this.team, required this.score});

  final String team;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          score?.toString() ?? '–',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(team, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
