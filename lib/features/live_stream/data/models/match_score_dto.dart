import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/match_score.dart';

/// Wire format for a live score frame pushed over the WebSocket.
class MatchScoreDto {
  const MatchScoreDto({
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    required this.minute,
  });

  factory MatchScoreDto.fromJson(Map<String, dynamic> json) {
    return MatchScoreDto(
      matchId: json['match_id'] as String,
      homeScore: (json['home_score'] as num?)?.toInt() ?? 0,
      awayScore: (json['away_score'] as num?)?.toInt() ?? 0,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
    );
  }

  final String matchId;
  final int homeScore;
  final int awayScore;
  final int minute;

  MatchScore toEntity() => MatchScore(
    matchId: matchId,
    homeScore: homeScore,
    awayScore: awayScore,
    minute: minute,
  );
}
