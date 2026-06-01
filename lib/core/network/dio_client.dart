import 'package:dio/dio.dart';

/// Base URL for the StreamHive backend.
///
/// Point this at your real API host. For per-flavor hosts, pass the value in
/// from `bootstrap` / the `main_*.dart` entrypoints instead of hard-coding it.
const String kApiBaseUrl = 'https://api.streamhive.example.com';

/// Builds the shared [Dio] instance used by every remote data source.
///
/// Centralising it here means cross-cutting concerns — auth headers, retries,
/// logging, timeouts — are configured in exactly one place.
Dio buildDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true),
  );

  // Add an auth interceptor here (inject the bearer token, refresh on 401)
  // once the auth feature exists.

  return dio;
}
