import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/matches/data/datasources/matches_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/entities/matches.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/repositories/matches_repository.dart';
import 'package:fpdart/fpdart.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  const MatchesRepositoryImpl({required MatchesRemoteDataSource remote})
    : _remote = remote;

  final MatchesRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Matches>>> getAll() async {
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
