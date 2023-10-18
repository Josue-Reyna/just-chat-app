import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';
import 'package:just_chat_app/models/profile.dart';
import 'package:just_chat_app/models/room.dart';
import 'package:just_chat_app/provider/theme_provider.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:provider/provider.dart';

part 'rooms_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit() : super(RoomsLoading());

  late final String _myUserId;

  late final List<Profile> _newUsers;

  List<Room> _rooms = [];
  List<Room> _groups = [];
  int _groupsLength = 0;
  StreamSubscription<List<Map<String, dynamic>>>? _rawRoomsSubscription;
  bool _haveCalledGetRooms = false;

  Future<void> initializeRooms(BuildContext context) async {
    if (_haveCalledGetRooms) {
      return;
    }
    _haveCalledGetRooms = true;
    _myUserId = supabase.auth.currentUser!.id;
    late final List data;
    BlocProvider.of<ProfilesCubit>(context).updateStatus(true);
    try {
      data = await supabase
          .from('profiles')
          .select()
          .not('id', 'eq', _myUserId)
          .order('created_at')
          .limit(12);
    } catch (_) {
      emit(RoomsError('Error loading new users'));
    }
    try {
      final dataColor = await supabase
          .from(
            'profiles',
          )
          .select()
          .match({
        'id': _myUserId,
      }).single();
      final profile = Profile.fromMap(dataColor);
      // ignore: use_build_context_synchronously
      final provider = Provider.of<ThemeProvider>(
        context,
        listen: false,
      );
      provider.changeColor(profile.color);
    } catch (_) {
      emit(RoomsError('Error loading theme color'));
    }

    final rows = List<Map<String, dynamic>>.from(data);
    _newUsers = rows.map(Profile.fromMap).toList();

    _rawRoomsSubscription = supabase
        .from('room_participants')
        .stream(
          primaryKey: [
            'room_id',
            'profile_id',
          ],
        )
        .order('message_time')
        .listen((participantMaps) async {
          if (participantMaps.isEmpty) {
            emit(RoomsEmpty(newUsers: _newUsers));
            return;
          }
          _rooms = participantMaps
              .map(Room.fromRoomParticipants)
              .where(
                  (room) => room.otherUserId != _myUserId && room.group == null)
              .toList();
          _groups = participantMaps
              .map(Room.fromRoomParticipants)
              .where(
                  (room) => room.otherUserId == _myUserId && room.group != null)
              .toList();
          for (final room in _rooms) {
            BlocProvider.of<ProfilesCubit>(context).getProfile(
              room.otherUserId!,
            );
          }
          _groupsLength = _groups.length;
          if (_groups.isNotEmpty) {
            for (var group in _groups) {
              _rooms.add(group);
            }
          }
          emit(
            RoomsLoaded(
              rooms: _rooms,
              newUsers: _newUsers,
              groups: _groupsLength,
            ),
          );
        }, onError: (error) {
          emit(
            RoomsError(
              'Error loading chat rooms',
            ),
          );
        });
  }

  Future<Map<String, dynamic>> createRoom(String otherUserId) async {
    final color = Random().nextInt(8);
    final data = await supabase.rpc(
      'create_new_room',
      params: {
        'other_user_id': otherUserId,
        'color': color,
      },
    );
    emit(
      RoomsLoaded(
        rooms: _rooms,
        newUsers: _newUsers,
        groups: _groupsLength,
      ),
    );
    final map = {
      'id': data.toString(),
      'color': color,
    };
    return map;
  }

  Future<String> createGroupParameters(
    List<String> otherUsers,
    int color,
    Map<String, dynamic> group,
  ) async {
    final String data = await supabase.rpc(
      'create_new_group_parameters_new',
      params: {
        'other_users': otherUsers,
        'color': color,
        'group_info': group,
        'members': otherUsers.length,
      },
    );
    emit(
      RoomsLoaded(
        rooms: _rooms,
        newUsers: _newUsers,
        groups: _groupsLength,
      ),
    );
    return data;
  }

  Future<Map<String, dynamic>> roomExistsNew(String otherUserId) async {
    final String data = await supabase.rpc(
      'create_new_room_exists_new_2',
      params: {
        'other_user_id': otherUserId,
      },
    );
    final things = data.split(' ');
    final Map<String, dynamic> map = {
      'color': things[0],
      'exists': things[1],
      'room_id': things[2],
    };
    return map;
  }

  void deleteRoom(String roomId) async {
    try {
      final List<dynamic> data =
          await supabase.from('messages').select('content').match({
        'room_id': roomId,
        'is_text': false,
      });
      await supabase.from('rooms').delete().eq('id', roomId);
      if (data.isNotEmpty) {
        for (var i = 0; i < data.length; i++) {
          await supabase.storage
              .from('chats')
              .remove([data[i]['content']!.substring(70, 135)]);
        }
        await supabase.storage.from('chats').remove(['$roomId-chat']);
      }
      emit(
        RoomsLoaded(
          rooms: _rooms,
          newUsers: _newUsers,
          groups: _groupsLength,
        ),
      );
    } catch (_) {
      emit(
        RoomsError(
          'Error deleting room',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _rawRoomsSubscription?.cancel();
    return super.close();
  }
}
