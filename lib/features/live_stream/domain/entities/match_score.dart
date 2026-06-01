import 'package:equatable/equatable.dart';

/// A point-in-time score for a live match.
///
/// Emitted repeatedly over the lifetime of a match (e.g. from a WebSocket) to
/// drive a live score overlay.
class MatchScore extends Equatable {
  const MatchScore({
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    required this.minute,
  });

  final String matchId;
  final int homeScore;
  final int awayScore;

  /// The match clock, in minutes.
  final int minute;

  @override
  List<Object?> get props => [matchId, homeScore, awayScore, minute];
}
