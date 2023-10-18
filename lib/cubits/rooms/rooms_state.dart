part of 'rooms_cubit.dart';

@immutable
abstract class RoomState {}

class RoomsLoading extends RoomState {}

class RoomsLoaded extends RoomState {
  final List<Profile> newUsers;
  final List<Room> rooms;
  final int groups;

  RoomsLoaded({
    required this.rooms,
    required this.newUsers,
    required this.groups,
  });
}

class RoomsEmpty extends RoomState {
  final List<Profile> newUsers;

  RoomsEmpty({required this.newUsers});
}

class RoomsError extends RoomState {
  final String message;

  RoomsError(this.message);
}
