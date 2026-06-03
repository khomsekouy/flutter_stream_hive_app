part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final AuthStatus status;
  final List<Auth> items;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    List<Auth>? items,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
