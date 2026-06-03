import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/entities/profile.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileRemoteDataSource remote})
    : _remote = remote;

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Profile>>> getAll() async {
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
