import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/entities/auth.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches all Auth items.
class GetAuthList extends UseCase<List<Auth>, NoParams> {
  const GetAuthList(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, List<Auth>>> call(NoParams params) {
    return _repository.getAll();
  }
}
