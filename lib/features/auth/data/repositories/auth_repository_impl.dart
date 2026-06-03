import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/entities/auth.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource remote})
    : _remote = remote;

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Auth>>> getAll() async {
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
