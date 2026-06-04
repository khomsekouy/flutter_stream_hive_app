import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/network/dio_client.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/data/datasources/highlight_list_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/data/repositories/highlight_list_repository_impl.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/repositories/highlight_list_repository.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/usecases/get_highlight_list_list.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/presentation/cubit/highlight_list_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_ws_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/repositories/live_stream_repository_impl.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/repositories/live_stream_repository.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/get_live_streams.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/get_stream_by_id.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/watch_match_score.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/live_stream_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/match_score_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/stream_detail_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/saved/saved_streams_store.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/content/profile_content.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/favorites/favorite_teams_store.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Registers every dependency. Call once from `bootstrap` before `runApp`.
Future<void> configureDependencies() async {
  getIt
    // ---- Core ----
    ..registerLazySingleton<Dio>(buildDioClient)
    ..registerLazySingleton(SavedStreamsStore.new)
    ..registerLazySingleton(
      () => FavoriteTeamsStore(initial: kFavoriteTeams),
    )
    // ---- Data sources (fakes for now) ----
    ..registerLazySingleton<LiveStreamRemoteDataSource>(
      FakeLiveStreamRemoteDataSource.new,
    )
    ..registerLazySingleton<LiveStreamWsDataSource>(
      FakeLiveStreamWsDataSource.new,
    )
    ..registerLazySingleton<HighlightListRemoteDataSource>(
      FakeHighlightListRemoteDataSource.new,
    )
    // ---- Repositories ----
    ..registerLazySingleton<LiveStreamRepository>(
      () => LiveStreamRepositoryImpl(remote: getIt(), ws: getIt()),
    )
    ..registerLazySingleton<HighlightListRepository>(
      () => HighlightListRepositoryImpl(remote: getIt()),
    )
    // ---- Use cases ----
    ..registerFactory(() => GetLiveStreams(getIt()))
    ..registerFactory(() => GetStreamById(getIt()))
    ..registerFactory(() => WatchMatchScore(getIt()))
    ..registerFactory(() => GetHighlightListList(getIt()))
    // ---- Presentation (cubits) ----
    ..registerFactory(() => LiveStreamCubit(getLiveStreams: getIt()))
    ..registerFactory(
      () => HighlightListCubit(getHighlightListList: getIt()),
    )
    ..registerFactoryParam<MatchScoreCubit, String, void>(
      (matchId, _) =>
          MatchScoreCubit(watchMatchScore: getIt(), matchId: matchId),
    )
    ..registerFactoryParam<StreamDetailCubit, String, LiveStream?>(
      (streamId, initial) => StreamDetailCubit(
        getStreamById: getIt(),
        streamId: streamId,
        initial: initial,
      ),
    );
}
