import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/live_stream_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/stream_card.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the feature.
///
/// The page's only job is wiring: pull a fully-built [LiveStreamCubit] from the
/// DI container and kick off the initial load. The [LiveStreamView] below is a
/// pure function of state and is what we'd test in isolation.
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

class LiveStreamView extends StatelessWidget {
  const LiveStreamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live now'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LiveStreamCubit>().loadLiveStreams(),
          ),
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
              if (state.streams.isEmpty) {
                return const Center(child: Text('No live streams right now.'));
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<LiveStreamCubit>().loadLiveStreams(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.streams.length,
                  itemBuilder: (context, index) {
                    final stream = state.streams[index];
                    return StreamCard(
                      stream: stream,
                      onTap: () => context.pushNamed(
                        AppRoute.streamDetail,
                        pathParameters: {'id': stream.id},
                        extra: stream,
                      ),
                    );
                  },
                ),
              );
          }
        },
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
