part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final ProfileStatus status;
  final List<Profile> items;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    List<Profile>? items,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
