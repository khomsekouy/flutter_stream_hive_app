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
      thumbnailUrl: 'https://picsum.photos/seed/epl-ars-che/200/200',
      viewerCount: 48213,
      commentCount: 328,
      competition: 'Premier League',
      homeTeam: 'Arsenal',
      awayTeam: 'Chelsea',
      venue: 'Emirates Stadium',
      homeScore: 2,
      awayScore: 1,
      minute: 65,
    ),
    const LiveStreamDto(
      id: 'ucl-rma-bar',
      title: 'Real Madrid vs Barcelona',
      status: 'live',
      hlsUrl: 'https://stream.example.com/ucl-rma-bar/master.m3u8',
      sport: 'football',
      thumbnailUrl: 'https://picsum.photos/seed/ucl-rma-bar/200/200',
      viewerCount: 152340,
      commentCount: 1204,
      competition: 'Champions League',
      homeTeam: 'Real Madrid',
      awayTeam: 'Barcelona',
      venue: 'Santiago Bernabéu',
      homeScore: 1,
      awayScore: 0,
      minute: 32,
    ),
    const LiveStreamDto(
      id: 'ucl-bay-juv',
      title: 'Bayern München vs Juventus',
      status: 'live',
      hlsUrl: 'https://stream.example.com/ucl-bay-juv/master.m3u8',
      sport: 'football',
      thumbnailUrl: 'https://picsum.photos/seed/ucl-bay-juv/200/200',
      viewerCount: 89412,
      commentCount: 642,
      competition: 'Champions League',
      homeTeam: 'Bayern München',
      awayTeam: 'Juventus',
      venue: 'Allianz Arena',
      homeScore: 3,
      awayScore: 2,
      minute: 78,
    ),
    const LiveStreamDto(
      id: 'epl-liv-mci',
      title: 'Liverpool vs Manchester City',
      status: 'live',
      hlsUrl: 'https://stream.example.com/epl-liv-mci/master.m3u8',
      sport: 'football',
      thumbnailUrl: 'https://picsum.photos/seed/epl-liv-mci/200/200',
      viewerCount: 73650,
      commentCount: 415,
      competition: 'Premier League',
      homeTeam: 'Liverpool',
      awayTeam: 'Manchester City',
      venue: 'Anfield',
      homeScore: 0,
      awayScore: 0,
      minute: 12,
    ),
    const LiveStreamDto(
      id: 'nba-lal-bos',
      title: 'Lakers vs Celtics',
      status: 'live',
      hlsUrl: 'https://stream.example.com/nba-lal-bos/master.m3u8',
      sport: 'basketball',
      thumbnailUrl: 'https://picsum.photos/seed/nba-lal-bos/200/200',
      viewerCount: 31987,
      commentCount: 188,
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
      thumbnailUrl: 'https://picsum.photos/seed/atp-final/200/200',
      viewerCount: 12045,
      commentCount: 96,
      competition: 'ATP Finals',
      homeTeam: 'Alcaraz',
      awayTeam: 'Sinner',
    ),
    // No thumbnailUrl on purpose — exercises the sport-icon fallback.
    const LiveStreamDto(
      id: 'f1-monaco',
      title: 'Monaco Grand Prix — Live',
      status: 'live',
      hlsUrl: 'https://stream.example.com/f1-monaco/master.m3u8',
      sport: 'motorsport',
      viewerCount: 67520,
      competition: 'Formula 1',
    ),
    // ---- Upcoming (drives the "Upcoming Matches" section) ----
    const LiveStreamDto(
      id: 'ucl-che-psg',
      title: 'Chelsea vs Paris Saint-Germain',
      status: 'upcoming',
      hlsUrl: 'https://stream.example.com/ucl-che-psg/master.m3u8',
      sport: 'football',
      competition: 'Champions League',
      homeTeam: 'Chelsea',
      awayTeam: 'Paris Saint-Germain',
      startTime: '2026-06-02T20:00:00Z',
      venue: 'Stamford Bridge',
    ),
    const LiveStreamDto(
      id: 'laliga-atm-bar',
      title: 'Atlético Madrid vs Barcelona',
      status: 'upcoming',
      hlsUrl: 'https://stream.example.com/laliga-atm-bar/master.m3u8',
      sport: 'football',
      competition: 'La Liga',
      homeTeam: 'Atlético Madrid',
      awayTeam: 'Barcelona',
      startTime: '2026-06-03T19:30:00Z',
      venue: 'Metropolitano',
    ),
    const LiveStreamDto(
      id: 'seriea-int-juv',
      title: 'Inter vs Juventus',
      status: 'upcoming',
      hlsUrl: 'https://stream.example.com/seriea-int-juv/master.m3u8',
      sport: 'football',
      competition: 'Serie A',
      homeTeam: 'Inter',
      awayTeam: 'Juventus',
      startTime: '2026-06-04T20:45:00Z',
      venue: 'San Siro',
    ),
    // ---- Finished (drives the "Finished" group on the Matches tab) ----
    const LiveStreamDto(
      id: 'epl-mci-liv',
      title: 'Manchester City vs Liverpool',
      status: 'ended',
      hlsUrl: 'https://stream.example.com/epl-mci-liv/master.m3u8',
      sport: 'football',
      competition: 'Premier League',
      homeTeam: 'Manchester City',
      awayTeam: 'Liverpool',
      startTime: '2026-06-01T16:30:00Z',
      venue: 'Etihad Stadium',
      homeScore: 4,
      awayScore: 1,
    ),
    const LiveStreamDto(
      id: 'ucl-rma-juv',
      title: 'Real Madrid vs Juventus',
      status: 'ended',
      hlsUrl: 'https://stream.example.com/ucl-rma-juv/master.m3u8',
      sport: 'football',
      competition: 'Champions League',
      homeTeam: 'Real Madrid',
      awayTeam: 'Juventus',
      startTime: '2026-06-01T20:00:00Z',
      venue: 'Santiago Bernabéu',
      homeScore: 2,
      awayScore: 0,
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
