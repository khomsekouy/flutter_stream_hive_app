import 'package:flutter_stream_hive_app/features/auth/domain/entities/auth.dart';

/// Wire format for the Auth entity (knows JSON; maps via toEntity()).
class AuthDto {
  const AuthDto({required this.id, required this.name});

  factory AuthDto.fromJson(Map<String, dynamic> json) {
    return AuthDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  final String id;
  final String name;

  Auth toEntity() => Auth(id: id, name: name);
}
