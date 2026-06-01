import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';

/// Data Transfer Object: the wire format of a stream as the API returns it.
///
/// Unlike the [LiveStream] entity, a DTO *does* know about JSON. Keeping it
/// separate means a backend field rename only touches this file — the entity
/// and everything above it stays put. `toEntity()` is the one-way bridge into
/// the domain.
class LiveStreamDto {
  const LiveStreamDto({
    required this.id,
    required this.title,
    required this.status,
    required this.hlsUrl,
    required this.sport,
    this.thumbnailUrl,
    this.viewerCount = 0,
    this.competition,
    this.homeTeam,
    this.awayTeam,
    this.startTime,
  });

  factory LiveStreamDto.fromJson(Map<String, dynamic> json) {
    return LiveStreamDto(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String? ?? 'upcoming',
      hlsUrl: json['hls_url'] as String? ?? '',
      sport: json['sport'] as String? ?? 'unknown',
      thumbnailUrl: json['thumbnail_url'] as String?,
      viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
      competition: json['competition'] as String?,
      homeTeam: json['home_team'] as String?,
      awayTeam: json['away_team'] as String?,
      startTime: json['start_time'] as String?,
    );
  }

  final String id;
  final String title;
  final String status;
  final String hlsUrl;
  final String sport;
  final String? thumbnailUrl;
  final int viewerCount;
  final String? competition;
  final String? homeTeam;
  final String? awayTeam;
  final String? startTime;

  LiveStream toEntity() {
    final thumbnail = thumbnailUrl;
    final start = startTime;
    return LiveStream(
      id: id,
      title: title,
      status: _statusFromString(status),
      hlsUrl: Uri.tryParse(hlsUrl) ?? Uri(),
      sport: sport,
      thumbnailUrl: thumbnail == null ? null : Uri.tryParse(thumbnail),
      viewerCount: viewerCount,
      competition: competition,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      startTime: start == null ? null : DateTime.tryParse(start),
    );
  }

  static StreamStatus _statusFromString(String value) {
    switch (value) {
      case 'live':
        return StreamStatus.live;
      case 'ended':
        return StreamStatus.ended;
      case 'upcoming':
      default:
        return StreamStatus.upcoming;
    }
  }
}
