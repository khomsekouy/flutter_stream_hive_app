import 'package:flutter_stream_hive_app/features/profile/domain/entities/profile.dart';

/// Wire format for the Profile entity (knows JSON; maps via toEntity()).
class ProfileDto {
  const ProfileDto({required this.id, required this.name});

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  final String id;
  final String name;

  Profile toEntity() => Profile(id: id, name: name);
}
