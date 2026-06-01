import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_ws_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/match_score.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/repositories/live_stream_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Implements the domain's [LiveStreamRepository] contract.
///
/// Its three jobs: orchestrate the data sources, map DTOs to entities, and
/// translate low-level [Exception]s into domain [Failure]s. This is the only
/// place where "how data is fetched" and "what the domain knows" meet.
class LiveStreamRepositoryImpl implements LiveStreamRepository {
  const LiveStreamRepositoryImpl({
    required LiveStreamRemoteDataSource remote,
    required LiveStreamWsDataSource ws,
  }) : _remote = remote,
       _ws = ws;

  final LiveStreamRemoteDataSource _remote;
  final LiveStreamWsDataSource _ws;

  @override
  Future<Either<Failure, List<LiveStream>>> getLiveStreams({
    String? sport,
  }) async {
    try {
      final dtos = await _remote.getLiveStreams(sport: sport);
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on Exception {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, LiveStream>> getStreamById(String id) async {
    try {
      final dto = await _remote.getStreamById(id);
      return Right(dto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on Exception {
      return const Left(UnknownFailure());
    }
  }

  @override
  Stream<MatchScore> watchMatchScore(String matchId) {
    return _ws.watchMatchScore(matchId).map((dto) => dto.toEntity());
  }
}
