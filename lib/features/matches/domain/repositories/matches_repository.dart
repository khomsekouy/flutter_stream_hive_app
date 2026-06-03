import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/entities/matches.dart';
import 'package:fpdart/fpdart.dart';

/// Contract the domain needs; implemented in the data layer.
// ignore: one_member_abstracts
abstract class MatchesRepository {
  Future<Either<Failure, List<Matches>>> getAll();
}
