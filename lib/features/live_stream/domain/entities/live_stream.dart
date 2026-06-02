import 'package:equatable/equatable.dart';

/// Lifecycle of a broadcast.
enum StreamStatus { upcoming, live, ended }

/// A broadcastable sporting event — the central business object of the feature.
///
/// This is a **pure domain entity**: no JSON, no Flutter, no networking. It
/// holds data plus the business rules that operate on that data (`isWatchable`,
/// `hasMatch`). The data layer maps DTOs into this; the presentation layer
/// renders it.
class LiveStream extends Equatable {
  const LiveStream({
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
    this.venue,
    this.homeScore,
    this.awayScore,
    this.minute,
  });

  final String id;
  final String title;
  final StreamStatus status;

  /// HLS/DASH manifest the player consumes.
  final Uri hlsUrl;

  /// e.g. `football`, `basketball`, `tennis`.
  final String sport;
  final Uri? thumbnailUrl;
  final int viewerCount;

  /// e.g. `Premier League`. Null for non-match streams.
  final String? competition;
  final String? homeTeam;
  final String? awayTeam;
  final DateTime? startTime;

  /// Where the match is played, e.g. `Royal Stadium`. Null for non-venue
  /// streams.
  final String? venue;

  /// Current scoreline. Null until/unless the match has started; for list
  /// views the API denormalises the live score so we don't open a socket per
  /// row. The authoritative, ticking score still comes from `MatchScore`.
  final int? homeScore;
  final int? awayScore;

  /// Match clock in minutes, paired with the score above.
  final int? minute;

  bool get isLive => status == StreamStatus.live;

  /// True when we have a scoreline to render (both sides present).
  bool get hasScore => homeScore != null && awayScore != null;

  /// True only when the stream is live and has a usable playback URL.
  bool get isWatchable => isLive && hlsUrl.toString().isNotEmpty;

  /// True when this stream represents a head-to-head match (so we can show a
  /// live score). False for, say, a press conference or a highlights reel.
  bool get hasMatch => homeTeam != null && awayTeam != null;

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    hlsUrl,
    sport,
    thumbnailUrl,
    viewerCount,
    competition,
    homeTeam,
    awayTeam,
    startTime,
    venue,
    homeScore,
    awayScore,
    minute,
  ];
}
