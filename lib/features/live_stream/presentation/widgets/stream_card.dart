import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';

/// A single tappable row in the live-stream list.
///
/// A pure, dependency-free widget: it takes a [LiveStream] entity and an
/// [onTap], and renders. No cubit, no business logic — that keeps it reusable
/// and cheap to test.
class StreamCard extends StatelessWidget {
  const StreamCard({required this.stream, required this.onTap, super.key});

  final LiveStream stream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            _iconForSport(stream.sport),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          stream.title,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          stream.competition ?? stream.sport,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (stream.isLive) const _LiveBadge() else const SizedBox.shrink(),
            const SizedBox(height: 4),
            Text(
              _formatViewers(stream.viewerCount),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForSport(String sport) {
    switch (sport) {
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'motorsport':
        return Icons.sports_motorsports;
      default:
        return Icons.live_tv;
    }
  }

  static String _formatViewers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M watching';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K watching';
    }
    return '$count watching';
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
