import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/repositories/live_stream_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches a single stream by id.
///
/// This is what makes the detail route deep-linkable: given only a `/stream/:id`
/// URL (no preloaded object), the detail screen can still reconstruct itself by
/// calling this.
class GetStreamById extends UseCase<LiveStream, String> {
  const GetStreamById(this._repository);

  final LiveStreamRepository _repository;

  @override
  Future<Either<Failure, LiveStream>> call(String id) {
    return _repository.getStreamById(id);
  }
}
