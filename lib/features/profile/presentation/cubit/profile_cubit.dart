import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/entities/profile.dart';
import 'package:flutter_stream_hive_app/features/profile/domain/usecases/get_profile_list.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required GetProfileList getProfileList})
    : _getProfileList = getProfileList,
      super(const ProfileState());

  final GetProfileList _getProfileList;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _getProfileList(const NoParams());
    result.fold(
      (failure) => emit(
        ProfileState(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) => emit(
        ProfileState(status: ProfileStatus.success, items: items),
      ),
    );
  }
}
