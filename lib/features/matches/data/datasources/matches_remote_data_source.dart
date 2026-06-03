import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/features/matches/data/models/matches_dto.dart';

/// Raw remote (HTTP) access for Matches. Throws on failure.
// ignore: one_member_abstracts
abstract class MatchesRemoteDataSource {
  Future<List<MatchesDto>> getAll();
}

class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  const MatchesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<MatchesDto>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/matches');
      final data = response.data?['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => MatchesDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
