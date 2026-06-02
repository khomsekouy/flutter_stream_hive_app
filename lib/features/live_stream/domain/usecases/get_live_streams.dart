import 'package:equatable/equatable.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/repositories/live_stream_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Input for [GetLiveStreams].
class GetLiveStreamsParams extends Equatable {
  const GetLiveStreamsParams({this.sport});

  /// Optional sport filter (`football`, `tennis`, ...). Null returns all.
  final String? sport;

  @override
  List<Object?> get props => [sport];
}

/// Fetches the list of currently-live streams.
class GetLiveStreams extends UseCase<List<LiveStream>, GetLiveStreamsParams> {
  const GetLiveStreams(this._repository);

  final LiveStreamRepository _repository;

  @override
  Future<Either<Failure, List<LiveStream>>> call(GetLiveStreamsParams params) {
    return _repository.getLiveStreams(sport: params.sport);
  }
}
