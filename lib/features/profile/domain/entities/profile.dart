import 'package:equatable/equatable.dart';

/// Profile domain entity. Pure Dart — no JSON, no Flutter.
class Profile extends Equatable {
  const Profile({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
