part of 'highlight_list_cubit.dart';

enum HighlightListStatus { initial, loading, success, failure }

class HighlightListState extends Equatable {
  const HighlightListState({
    this.status = HighlightListStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final HighlightListStatus status;
  final List<HighlightList> items;
  final String? errorMessage;

  HighlightListState copyWith({
    HighlightListStatus? status,
    List<HighlightList>? items,
    String? errorMessage,
  }) {
    return HighlightListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
