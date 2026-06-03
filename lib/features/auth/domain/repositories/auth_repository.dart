import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/entities/auth.dart';
import 'package:fpdart/fpdart.dart';

/// Contract the domain needs; implemented in the data layer.
// ignore: one_member_abstracts
abstract class AuthRepository {
  Future<Either<Failure, List<Auth>>> getAll();
}
