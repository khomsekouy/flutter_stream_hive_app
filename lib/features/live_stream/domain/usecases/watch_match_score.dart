import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/match_score.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/repositories/live_stream_repository.dart';

/// Subscribes to live score updates for a given match id.
///
/// Demonstrates the real-time counterpart to `GetLiveStreams`: a
/// [StreamUseCase] backed by a WebSocket data source.
class WatchMatchScore extends StreamUseCase<MatchScore, String> {
  const WatchMatchScore(this._repository);

  final LiveStreamRepository _repository;

  @override
  Stream<MatchScore> call(String matchId) {
    return _repository.watchMatchScore(matchId);
  }
}
