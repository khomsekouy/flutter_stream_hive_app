import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/entities/highlight_list.dart';
import 'package:fpdart/fpdart.dart';

/// Contract the domain needs; implemented in the data layer.
// ignore: one_member_abstracts
abstract class HighlightListRepository {
  Future<Either<Failure, List<HighlightList>>> getAll();
}
