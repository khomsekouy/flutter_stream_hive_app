import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/get_live_streams.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/live_stream_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLiveStreams extends Mock implements GetLiveStreams {}

void main() {
  late _MockGetLiveStreams getLiveStreams;

  final streams = [
    LiveStream(
      id: '1',
      title: 'Arsenal vs Chelsea',
      status: StreamStatus.live,
      hlsUrl: Uri.parse('https://stream.example.com/1/master.m3u8'),
      sport: 'football',
    ),
  ];

  setUpAll(() => registerFallbackValue(const GetLiveStreamsParams()));

  setUp(() => getLiveStreams = _MockGetLiveStreams());

  group('LiveStreamCubit', () {
    blocTest<LiveStreamCubit, LiveStreamState>(
      'emits [loading, success] when the use case returns streams',
      build: () {
        when(() => getLiveStreams(any())).thenAnswer(
          (_) async => Right(streams),
        );
        return LiveStreamCubit(getLiveStreams: getLiveStreams);
      },
      act: (cubit) => cubit.loadLiveStreams(),
      expect: () => [
        const LiveStreamState(status: LiveStreamStatus.loading),
        LiveStreamState(status: LiveStreamStatus.success, streams: streams),
      ],
    );

    blocTest<LiveStreamCubit, LiveStreamState>(
      'emits [loading, failure] when the use case returns a Failure',
      build: () {
        when(() => getLiveStreams(any())).thenAnswer(
          (_) async => const Left(ServerFailure('boom')),
        );
        return LiveStreamCubit(getLiveStreams: getLiveStreams);
      },
      act: (cubit) => cubit.loadLiveStreams(),
      expect: () => [
        const LiveStreamState(status: LiveStreamStatus.loading),
        const LiveStreamState(
          status: LiveStreamStatus.failure,
          errorMessage: 'boom',
        ),
      ],
    );
  });
}
