import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/match_score.dart';
import 'package:fpdart/fpdart.dart';

/// The contract the domain layer needs from the outside world.
///
/// This is the **dependency inversion** at the heart of clean architecture:
/// the domain *declares* what it needs here, and the data layer *implements*
/// it (`LiveStreamRepositoryImpl`). The arrow points inward — data depends on
/// domain, never the reverse — so the video/score backend can be swapped with
/// zero changes above this line.
abstract class LiveStreamRepository {
  /// All currently-live streams, optionally filtered by [sport].
  Future<Either<Failure, List<LiveStream>>> getLiveStreams({String? sport});

  /// A single stream by id (used by the detail/player screen).
  Future<Either<Failure, LiveStream>> getStreamById(String id);

  /// A continuous feed of score updates for a match.
  ///
  /// Returns a raw [Stream] (not an [Either]) because real-time errors are
  /// delivered through the stream's own error channel.
  Stream<MatchScore> watchMatchScore(String matchId);
}
