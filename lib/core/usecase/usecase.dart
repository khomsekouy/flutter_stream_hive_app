import 'package:equatable/equatable.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// A single, self-contained business action.
///
/// One use case = one verb the app can perform (`GetLiveStreams`,
/// `SignIn`, ...). Use cases depend only on repository *interfaces*, so they
/// are pure Dart and trivially unit-testable.
///
/// [T] is the success payload; [Params] is the input (use [NoParams] when
/// there is none). The result is an [Either]: `Left` on [Failure],
/// `Right` on success — so callers must handle the error path explicitly.
// ignore: one_member_abstracts
abstract class UseCase<T, Params> {
  const UseCase();

  Future<Either<Failure, T>> call(Params params);
}

/// A use case that yields a continuous stream of values rather than a single
/// future — e.g. a live match score over a WebSocket.
///
/// Streams surface their own errors through `Stream.onError`, so the value
/// type is exposed directly instead of being wrapped in [Either].
// ignore: one_member_abstracts
abstract class StreamUseCase<T, Params> {
  const StreamUseCase();

  Stream<T> call(Params params);
}

/// Placeholder for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
