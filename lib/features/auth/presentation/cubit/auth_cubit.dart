import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/usecase/usecase.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/entities/auth.dart';
import 'package:flutter_stream_hive_app/features/auth/domain/usecases/get_auth_list.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required GetAuthList getAuthList})
    : _getAuthList = getAuthList,
      super(const AuthState());

  final GetAuthList _getAuthList;

  Future<void> load() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _getAuthList(const NoParams());
    result.fold(
      (failure) => emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) => emit(
        AuthState(status: AuthStatus.success, items: items),
      ),
    );
  }
}
