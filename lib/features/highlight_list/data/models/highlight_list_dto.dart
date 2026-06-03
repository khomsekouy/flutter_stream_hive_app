import 'package:flutter_stream_hive_app/features/highlight_list/domain/entities/highlight_list.dart';

/// Wire format for the HighlightList entity (knows JSON; maps via toEntity()).
class HighlightListDto {
  const HighlightListDto({
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

  factory HighlightListDto.fromJson(Map<String, dynamic> json) {
    return HighlightListDto(
      id: json['id'] as String,
      homeTeam: json['home_team'] as String? ?? '',
      awayTeam: json['away_team'] as String? ?? '',
      homeScore: (json['home_score'] as num?)?.toInt() ?? 0,
      awayScore: (json['away_score'] as num?)?.toInt() ?? 0,
      league: json['league'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      timeAgo: json['time_ago'] as String? ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      isHot: json['is_hot'] as bool? ?? false,
    );
  }

  final String id;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String league;
  final String duration;
  final String timeAgo;
  final int views;
  final String thumbnailUrl;
  final bool isHot;

  HighlightList toEntity() => HighlightList(
    id: id,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    homeScore: homeScore,
    awayScore: awayScore,
    league: league,
    duration: duration,
    timeAgo: timeAgo,
    views: views,
    thumbnailUrl: thumbnailUrl,
    isHot: isHot,
  );
}
