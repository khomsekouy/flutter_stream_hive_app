import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/features/profile/data/models/profile_dto.dart';

/// Raw remote (HTTP) access for Profile. Throws on failure.
// ignore: one_member_abstracts
abstract class ProfileRemoteDataSource {
  Future<List<ProfileDto>> getAll();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ProfileDto>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/profile');
      final data = response.data?['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => ProfileDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
