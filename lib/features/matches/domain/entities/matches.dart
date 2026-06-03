import 'package:equatable/equatable.dart';

/// Matches domain entity. Pure Dart — no JSON, no Flutter.
class Matches extends Equatable {
  const Matches({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
