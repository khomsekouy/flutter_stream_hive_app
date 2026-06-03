import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/entities/highlight_list.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/repositories/highlight_list_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches all HighlightList items.
class GetHighlightListList extends UseCase<List<HighlightList>, NoParams> {
  const GetHighlightListList(this._repository);

  final HighlightListRepository _repository;

  @override
  Future<Either<Failure, List<HighlightList>>> call(NoParams params) {
    return _repository.getAll();
  }
}
