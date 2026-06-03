import 'package:equatable/equatable.dart';

/// Auth domain entity. Pure Dart — no JSON, no Flutter.
class Auth extends Equatable {
  const Auth({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
