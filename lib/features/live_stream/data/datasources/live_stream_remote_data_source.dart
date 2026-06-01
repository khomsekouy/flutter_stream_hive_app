import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/features/live_stream/data/models/live_stream_dto.dart';

/// Raw REST access for streams. Talks JSON, throws [ServerException].
///
/// The abstraction lets the repository depend on a seam it can mock in tests,
/// and lets us ship the [FakeLiveStreamRemoteDataSource] until the real
/// backend exists.
abstract class LiveStreamRemoteDataSource {
  Future<List<LiveStreamDto>> getLiveStreams({String? sport});

  Future<LiveStreamDto> getStreamById(String id);
}

/// The production implementation — backed by [Dio].
class LiveStreamRemoteDataSourceImpl implements LiveStreamRemoteDataSource {
  const LiveStreamRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<LiveStreamDto>> getLiveStreams({String? sport}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/streams',
        queryParameters: <String, dynamic>{
          'status': 'live',
          'sport': ?sport,
        },
      );
      final data = response.data?['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => LiveStreamDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load streams',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<LiveStreamDto> getStreamById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/streams/$id');
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException(message: 'Stream not found');
      }
      return LiveStreamDto.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load stream',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

/// In-memory sample data so the app runs end-to-end before the backend is
/// ready. Swap it for [LiveStreamRemoteDataSourceImpl] in `injection.dart`
/// once your API is live.
class FakeLiveStreamRemoteDataSource implements LiveStreamRemoteDataSource {
  static final List<LiveStreamDto> _samples = [
    const LiveStreamDto(
      id: 'epl-ars-che',
      title: 'Arsenal vs Chelsea',
      status: 'live',
      hlsUrl: 'https://stream.example.com/epl-ars-che/master.m3u8',
      sport: 'football',
      viewerCount: 48213,
      competition: 'Premier League',
      homeTeam: 'Arsenal',
      awayTeam: 'Chelsea',
    ),
    const LiveStreamDto(
      id: 'nba-lal-bos',
      title: 'Lakers vs Celtics',
      status: 'live',
      hlsUrl: 'https://stream.example.com/nba-lal-bos/master.m3u8',
      sport: 'basketball',
      viewerCount: 31987,
      competition: 'NBA',
      homeTeam: 'Lakers',
      awayTeam: 'Celtics',
    ),
    const LiveStreamDto(
      id: 'atp-final',
      title: 'ATP Finals — Singles Final',
      status: 'live',
      hlsUrl: 'https://stream.example.com/atp-final/master.m3u8',
      sport: 'tennis',
      viewerCount: 12045,
      competition: 'ATP Finals',
      homeTeam: 'Alcaraz',
      awayTeam: 'Sinner',
    ),
    const LiveStreamDto(
      id: 'f1-monaco',
      title: 'Monaco Grand Prix — Live',
      status: 'live',
      hlsUrl: 'https://stream.example.com/f1-monaco/master.m3u8',
      sport: 'motorsport',
      viewerCount: 67520,
      competition: 'Formula 1',
    ),
  ];

  @override
  Future<List<LiveStreamDto>> getLiveStreams({String? sport}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (sport == null) return _samples;
    return _samples.where((s) => s.sport == sport).toList();
  }

  @override
  Future<LiveStreamDto> getStreamById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final match = _samples.where((s) => s.id == id);
    if (match.isEmpty) {
      throw const ServerException(message: 'Stream not found');
    }
    return match.first;
  }
}
