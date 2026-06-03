import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/data/models/highlight_list_dto.dart';

/// Raw remote (HTTP) access for HighlightList. Throws on failure.
// ignore: one_member_abstracts
abstract class HighlightListRemoteDataSource {
  Future<List<HighlightListDto>> getAll();
}

class HighlightListRemoteDataSourceImpl
    implements HighlightListRemoteDataSource {
  const HighlightListRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<HighlightListDto>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/highlight_list',
      );
      final data = response.data?['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => HighlightListDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

/// In-memory sample data so the screen works before the backend is ready.
/// Swap for [HighlightListRemoteDataSourceImpl] in `injection.dart` once the
/// API is live.
class FakeHighlightListRemoteDataSource
    implements HighlightListRemoteDataSource {
  static const List<HighlightListDto> _samples = [
    HighlightListDto(
      id: 'hl-1',
      homeTeam: 'Real Madrid',
      awayTeam: 'Barcelona',
      homeScore: 3,
      awayScore: 2,
      league: 'Champions League',
      duration: '05:24',
      timeAgo: '2 hours ago',
      views: 45200,
      thumbnailUrl: 'https://picsum.photos/seed/hl-rma-bar/640/360',
      isHot: true,
    ),
    HighlightListDto(
      id: 'hl-2',
      homeTeam: 'Manchester City',
      awayTeam: 'Liverpool',
      homeScore: 4,
      awayScore: 1,
      league: 'Premier League',
      duration: '04:18',
      timeAgo: '5 hours ago',
      views: 32100,
      thumbnailUrl: 'https://picsum.photos/seed/hl-mci-liv/640/360',
    ),
    HighlightListDto(
      id: 'hl-3',
      homeTeam: 'Atlético Madrid',
      awayTeam: 'Barcelona',
      homeScore: 2,
      awayScore: 1,
      league: 'La Liga',
      duration: '03:56',
      timeAgo: 'Yesterday',
      views: 28700,
      thumbnailUrl: 'https://picsum.photos/seed/hl-atm-bar/640/360',
    ),
    HighlightListDto(
      id: 'hl-4',
      homeTeam: 'Real Madrid',
      awayTeam: 'Juventus',
      homeScore: 2,
      awayScore: 0,
      league: 'Champions League',
      duration: '06:02',
      timeAgo: '1 day ago',
      views: 51400,
      thumbnailUrl: 'https://picsum.photos/seed/hl-rma-juv/640/360',
    ),
    HighlightListDto(
      id: 'hl-5',
      homeTeam: 'Chelsea',
      awayTeam: 'Arsenal',
      homeScore: 3,
      awayScore: 2,
      league: 'Premier League',
      duration: '04:35',
      timeAgo: '2 days ago',
      views: 44800,
      thumbnailUrl: 'https://picsum.photos/seed/hl-che-ars/640/360',
    ),
    HighlightListDto(
      id: 'hl-6',
      homeTeam: 'Bayern München',
      awayTeam: 'Juventus',
      homeScore: 5,
      awayScore: 0,
      league: 'Champions League',
      duration: '05:11',
      timeAgo: '3 days ago',
      views: 39600,
      thumbnailUrl: 'https://picsum.photos/seed/hl-bay-juv/640/360',
    ),
  ];

  @override
  Future<List<HighlightListDto>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _samples;
  }
}
