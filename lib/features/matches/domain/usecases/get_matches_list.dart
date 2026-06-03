import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/entities/matches.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/repositories/matches_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches all Matches items.
class GetMatchesList extends UseCase<List<Matches>, NoParams> {
  const GetMatchesList(this._repository);

  final MatchesRepository _repository;

  @override
  Future<Either<Failure, List<Matches>>> call(NoParams params) {
    return _repository.getAll();
  }
}
