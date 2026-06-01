import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/core/error/failures.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_remote_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/datasources/live_stream_ws_data_source.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/models/live_stream_dto.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/repositories/live_stream_repository_impl.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements LiveStreamRemoteDataSource {}

class _MockWs extends Mock implements LiveStreamWsDataSource {}

void main() {
  late _MockRemote remote;
  late _MockWs ws;
  late LiveStreamRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    ws = _MockWs();
    repository = LiveStreamRepositoryImpl(remote: remote, ws: ws);
  });

  group('LiveStreamRepositoryImpl.getLiveStreams', () {
    test('maps DTOs to domain entities on success', () async {
      when(() => remote.getLiveStreams(sport: any(named: 'sport'))).thenAnswer(
        (_) async => const [
          LiveStreamDto(
            id: '1',
            title: 'Arsenal vs Chelsea',
            status: 'live',
            hlsUrl: 'https://stream.example.com/1/master.m3u8',
            sport: 'football',
          ),
        ],
      );

      final result = await repository.getLiveStreams();

      expect(result.isRight(), isTrue);
      final streams = result.getRight().toNullable()!;
      expect(streams.single.id, '1');
      expect(streams.single.status, StreamStatus.live);
      expect(streams.single.isWatchable, isTrue);
    });

    test('returns ServerFailure when the data source throws', () async {
      when(() => remote.getLiveStreams(sport: any(named: 'sport')))
          .thenThrow(const ServerException(message: 'down'));

      final result = await repository.getLiveStreams();

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), const ServerFailure('down'));
    });
  });
}
