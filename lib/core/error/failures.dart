import 'package:equatable/equatable.dart';

/// The domain-friendly representation of something going wrong.
///
/// Use cases and the presentation layer only ever deal in [Failure]s — they
/// never see a [Exception], a `DioException`, or an HTTP status code. This is
/// what keeps the inner layers ignorant of how data is fetched.
abstract class Failure extends Equatable {
  const Failure(this.message);

  /// A human-readable, presentation-safe description.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// The server was reachable but returned an error.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

/// The device has no connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Reading cached data failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to read cached data.']);
}

/// Anything we did not explicitly anticipate.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
