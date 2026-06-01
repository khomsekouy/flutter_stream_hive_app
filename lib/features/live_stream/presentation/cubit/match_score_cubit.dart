import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/match_score.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/watch_match_score.dart';

part 'match_score_state.dart';

/// Drives the live score overlay on the detail screen.
///
/// The real-time analogue of `LiveStreamCubit`: instead of awaiting a future,
/// it subscribes to a `StreamUseCase` and re-emits state on every frame. It
/// owns the subscription and tears it down in [close] — leaking a WebSocket
/// subscription is the classic real-time bug.
class MatchScoreCubit extends Cubit<MatchScoreState> {
  MatchScoreCubit({
    required WatchMatchScore watchMatchScore,
    required String matchId,
  }) : _watchMatchScore = watchMatchScore,
       _matchId = matchId,
       super(const MatchScoreState());

  final WatchMatchScore _watchMatchScore;
  final String _matchId;
  StreamSubscription<MatchScore>? _subscription;

  void start() {
    unawaited(_subscription?.cancel());
    emit(state.copyWith(status: MatchScoreStatus.watching));
    _subscription = _watchMatchScore(_matchId).listen(
      (score) => emit(
        state.copyWith(status: MatchScoreStatus.watching, score: score),
      ),
      onError: (Object _) => emit(
        state.copyWith(status: MatchScoreStatus.failure),
      ),
      onDone: () => emit(state.copyWith(status: MatchScoreStatus.ended)),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
