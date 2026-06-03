import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/data/datasources/highlight_list_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/entities/highlight_list.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/repositories/highlight_list_repository.dart';
import 'package:fpdart/fpdart.dart';

class HighlightListRepositoryImpl implements HighlightListRepository {
  const HighlightListRepositoryImpl({
    required HighlightListRemoteDataSource remote,
  }) : _remote = remote;

  final HighlightListRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<HighlightList>>> getAll() async {
    try {
      final dtos = await _remote.getAll();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(UnknownFailure());
    }
  }
}
