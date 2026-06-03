import 'package:dio/dio.dart';
import 'package:flutter_stream_hive_app/core/error/exceptions.dart';
import 'package:flutter_stream_hive_app/features/auth/data/models/auth_dto.dart';

/// Raw remote (HTTP) access for Auth. Throws on failure.
// ignore: one_member_abstracts
abstract class AuthRemoteDataSource {
  Future<List<AuthDto>> getAll();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AuthDto>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/auth');
      final data = response.data?['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => AuthDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
