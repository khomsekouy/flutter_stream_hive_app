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
class LiveNowPage extends StatelessWidget {
  const LiveNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<LiveStreamCubit>();
        unawaited(cubit.loadLiveStreams());
        return cubit;
      },
      child: const LiveNowView(),
    );
  }
}

class LiveNowView extends StatelessWidget {
  const LiveNowView({super.key});

  void _openDetail(BuildContext context, LiveStream stream) =>
      context.pushNamed(
        AppRoute.streamDetail,
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
          'Live Now',
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
              final live = state.streams.where((s) => s.isLive).toList();
              if (live.isEmpty) {
                return const _CenteredMessage(
                  text: 'No live matches right now.',
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<LiveStreamCubit>().loadLiveStreams(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: live.length,
                  itemBuilder: (context, i) => LiveMatchCard(
                    match: live[i],
                    onTap: () => _openDetail(context, live[i]),
                  ),
                ),
              );
          }
        },
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
