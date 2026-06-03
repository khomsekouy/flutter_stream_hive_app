import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/entities/highlight_list.dart';
import 'package:flutter_stream_hive_app/features/highlight_list/domain/usecases/get_highlight_list_list.dart';

part 'highlight_list_state.dart';

class HighlightListCubit extends Cubit<HighlightListState> {
  HighlightListCubit({required GetHighlightListList getHighlightListList})
    : _getHighlightListList = getHighlightListList,
      super(const HighlightListState());

  final GetHighlightListList _getHighlightListList;

  Future<void> load() async {
    emit(state.copyWith(status: HighlightListStatus.loading));
    final result = await _getHighlightListList(const NoParams());
    result.fold(
      (failure) => emit(
        HighlightListState(
          status: HighlightListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) => emit(
        HighlightListState(status: HighlightListStatus.success, items: items),
      ),
    );
  }
}
