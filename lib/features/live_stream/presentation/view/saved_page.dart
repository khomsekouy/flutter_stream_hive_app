import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/saved/saved_streams_store.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:go_router/go_router.dart';

/// Full-screen list of the streams the user has saved.
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  void _openDetail(BuildContext context, LiveStream stream) =>
      context.pushNamed(
        AppRoute.streamDetail,
        pathParameters: {'id': stream.id},
        extra: stream,
      );

  @override
  Widget build(BuildContext context) {
    final store = getIt<SavedStreamsStore>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final items = store.items;
          if (items.isEmpty) {
            return const _EmptySaved();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final stream = items[i];
              return LiveMatchCard(
                match: stream,
                onTap: () => _openDetail(context, stream),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Nothing saved yet.\nTap the bookmark on a stream to save it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
