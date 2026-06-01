/// Low-level errors thrown by the **data layer** (data sources).
///
/// These are implementation details — they never cross into the domain or
/// presentation layers. The repository catches them and maps each one to a
/// `Failure` from `failures.dart`.
library;

/// Thrown when the backend responds with an error status or malformed body.
class ServerException implements Exception {
  const ServerException({this.message = 'Server error', this.statusCode});

  final String message;
  final int? statusCode;
}

/// Thrown when the device cannot reach the network at all.
class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});

  final String message;
}

/// Thrown when reading from or writing to the local cache fails.
class CacheException implements Exception {
  const CacheException({this.message = 'Cache error'});

  final String message;
}
