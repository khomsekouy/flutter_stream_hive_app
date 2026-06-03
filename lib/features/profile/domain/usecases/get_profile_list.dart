import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/entities/profile.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches all Profile items.
class GetProfileList extends UseCase<List<Profile>, NoParams> {
  const GetProfileList(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, List<Profile>>> call(NoParams params) {
    return _repository.getAll();
  }
}
