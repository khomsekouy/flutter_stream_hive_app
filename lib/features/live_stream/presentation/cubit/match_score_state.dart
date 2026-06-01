part of 'match_score_cubit.dart';

enum MatchScoreStatus { initial, watching, ended, failure }

class MatchScoreState extends Equatable {
  const MatchScoreState({this.status = MatchScoreStatus.initial, this.score});

  final MatchScoreStatus status;
  final MatchScore? score;

  MatchScoreState copyWith({MatchScoreStatus? status, MatchScore? score}) {
    return MatchScoreState(
      status: status ?? this.status,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [status, score];
}
