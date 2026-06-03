import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/entities/matches.dart';
import 'package:flutter_stream_hive_app/features/matches/domain/usecases/get_matches_list.dart';

part 'matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit({required GetMatchesList getMatchesList})
    : _getMatchesList = getMatchesList,
      super(const MatchesState());

  final GetMatchesList _getMatchesList;

  Future<void> load() async {
    emit(state.copyWith(status: MatchesStatus.loading));
    final result = await _getMatchesList(const NoParams());
    result.fold(
      (failure) => emit(
        MatchesState(
          status: MatchesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) => emit(
        MatchesState(status: MatchesStatus.success, items: items),
      ),
    );
  }
}
