part of 'profiles_cubit.dart';

@immutable
abstract class ProfilesState {}

class ProfilesInitial extends ProfilesState {}

class ProfilesLoaded extends ProfilesState {
  ProfilesLoaded({
    required this.profiles,
  });

  final Map<String, Profile?> profiles;
}

class ProfilesError extends ProfilesState {
  ProfilesError(this.message);
  final String message;
}
