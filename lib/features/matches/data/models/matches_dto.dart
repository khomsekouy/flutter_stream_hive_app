import 'package:flutter_stream_hive_app/features/matches/domain/entities/matches.dart';

/// Wire format for the Matches entity (knows JSON; maps via toEntity()).
class MatchesDto {
  const MatchesDto({required this.id, required this.name});

  factory MatchesDto.fromJson(Map<String, dynamic> json) {
    return MatchesDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  final String id;
  final String name;

  Matches toEntity() => Matches(id: id, name: name);
}
