import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/entities/profile.dart';
import 'package:fpdart/fpdart.dart';

/// Contract the domain needs; implemented in the data layer.
// ignore: one_member_abstracts
abstract class ProfileRepository {
  Future<Either<Failure, List<Profile>>> getAll();
}
