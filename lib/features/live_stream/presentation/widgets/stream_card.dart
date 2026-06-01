import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/gen/assets.gen.dart';

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
        leading: _StreamThumbnail(stream: stream),
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

/// The leading thumbnail.
///
/// Network thumbnails go through [CachedNetworkImage] (disk + memory cache,
/// so fast scrolling doesn't re-download). It degrades gracefully: a spinner
/// while loading, and [_Fallback] (a bundled placeholder asset under the sport
/// icon) when the URL is missing or the download fails.
class _StreamThumbnail extends StatelessWidget {
  const _StreamThumbnail({required this.stream});

  final LiveStream stream;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final url = stream.thumbnailUrl?.toString();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _size,
        height: _size,
        child: (url == null || url.isEmpty)
            ? _Fallback(sport: stream.sport)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => const ColoredBox(
                  color: Colors.black12,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, _, _) => _Fallback(sport: stream.sport),
              ),
      ),
    );
  }
}

/// Shown when there is no thumbnail, or the network image fails to load.
///
/// Uses the bundled placeholder via flutter_gen's type-safe
/// `Assets.images.streamPlaceholder` — no magic-string paths — with the sport
/// icon overlaid through a translucent scrim.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.sport});

  final String sport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Assets.images.streamPlaceholder.image(
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        ColoredBox(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.85),
          child: Icon(
            StreamCard._iconForSport(sport),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.appColors.live,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
