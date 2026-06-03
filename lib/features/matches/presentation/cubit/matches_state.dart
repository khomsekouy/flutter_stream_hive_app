part of 'matches_cubit.dart';

enum MatchesStatus { initial, loading, success, failure }

class MatchesState extends Equatable {
  const MatchesState({
    this.status = MatchesStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final MatchesStatus status;
  final List<Matches> items;
  final String? errorMessage;

  MatchesState copyWith({
    MatchesStatus? status,
    List<Matches>? items,
    String? errorMessage,
  }) {
    return MatchesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
