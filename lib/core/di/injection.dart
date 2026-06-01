import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/network/dio_client.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_ws_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/repositories/live_stream_repository_impl.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/repositories/live_stream_repository.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/get_live_streams.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/watch_match_score.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/live_stream_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/match_score_cubit.dart';
import 'package:get_it/get_it.dart';

/// The service locator — our single composition root.
///
/// As the outermost layer, this is the *only* place allowed to know about
/// every other layer at once. It wires concrete implementations to the
/// interfaces the inner layers depend on, so nothing else has to `new` up its
/// own dependencies.
final GetIt getIt = GetIt.instance;

/// Registers every dependency. Call once from `bootstrap` before `runApp`.
Future<void> configureDependencies() async {
  // Each section maps an interface (what inner layers depend on) to a concrete
  // implementation. Swap the fake data sources for their *Impl versions once
  // the backend is live — nothing above the data layer changes.
  getIt
    // ---- Core ----
    ..registerLazySingleton<Dio>(buildDioClient)
    // ---- Data sources (fakes for now) ----
    ..registerLazySingleton<LiveStreamRemoteDataSource>(
      FakeLiveStreamRemoteDataSource.new,
    )
    ..registerLazySingleton<LiveStreamWsDataSource>(
      FakeLiveStreamWsDataSource.new,
    )
    // ---- Repositories ----
    ..registerLazySingleton<LiveStreamRepository>(
      () => LiveStreamRepositoryImpl(remote: getIt(), ws: getIt()),
    )
    // ---- Use cases ----
    ..registerFactory(() => GetLiveStreams(getIt()))
    ..registerFactory(() => WatchMatchScore(getIt()))
    // ---- Presentation (cubits) ----
    ..registerFactory(() => LiveStreamCubit(getLiveStreams: getIt()))
    ..registerFactoryParam<MatchScoreCubit, String, void>(
      (matchId, _) =>
          MatchScoreCubit(watchMatchScore: getIt(), matchId: matchId),
    );
}
