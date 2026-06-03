import 'package:equatable/equatable.dart';

/// A single match-highlight reel. Pure Dart — no JSON, no Flutter.
class HighlightList extends Equatable {
  const HighlightList({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.league,
    required this.duration,
    required this.timeAgo,
    required this.views,
    required this.thumbnailUrl,
    this.isHot = false,
  });

  final String id;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;

  /// e.g. `Champions League`.
  final String league;

  /// Pre-formatted clip length, e.g. `05:24`.
  final String duration;

  /// Pre-formatted relative time, e.g. `2 hours ago`.
  final String timeAgo;

  /// Raw view count; the UI formats it (e.g. `45.2K views`).
  final int views;
  final String thumbnailUrl;

  /// Whether to flag this reel with a "HOT" badge.
  final bool isHot;

  /// "Home 3 - 2 Away".
  String get title => '$homeTeam $homeScore - $awayScore $awayTeam';

  @override
  List<Object?> get props => [
    id,
    homeTeam,
    awayTeam,
    homeScore,
    awayScore,
    league,
    duration,
    timeAgo,
    views,
    thumbnailUrl,
    isHot,
  ];
}
