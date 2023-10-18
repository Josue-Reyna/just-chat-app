import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:just_chat_app/models/message.dart';
import 'package:just_chat_app/models/room.dart';
import 'package:just_chat_app/services/encryption_service.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _colorSubscription;
  List<Room> rooms = [];
  late int _color;
  List<Message> _messages = [];

  late final String _roomId;
  late final String _myUserId;

  void updateGroupName(
    Map<String, dynamic> group,
    String groupName,
    String roomId,
  ) async {
    group.update('name', (value) => groupName);
    try {
      await supabase
          .from('room_participants')
          .update({'group_info': group}).match({'room_id': roomId});
      emit(
        ChatLoaded(
          _messages,
          _color,
        ),
      );
    } catch (_) {
      emit(
        ChatError(
          'Error saving new color',
        ),
      );
    }
  }

  void updateGroupBio(
    Map<String, dynamic> group,
    String groupBio,
    String roomId,
  ) async {
    group.update('group_bio', (value) => groupBio);
    try {
      await supabase
          .from('room_participants')
          .update({'group_info': group}).match({'room_id': roomId});
      emit(ChatLoaded(
        _messages,
        _color,
      ));
    } catch (_) {
      emit(
        ChatError(
          'Error saving new color',
        ),
      );
    }
  }

  void updateChatColor(int color, String id, String roomId) async {
    try {
      await supabase.from('room_participants').update(
          {'room_color': color}).match({'room_id': roomId, 'profile_id': id});
      _color = color;
      emit(ChatLoaded(
        _messages,
        _color,
      ));
    } catch (_) {
      emit(
        ChatError(
          'Error saving new color',
        ),
      );
    }
  }

  void updateGroupColor(int color, String roomId) async {
    try {
      await supabase
          .from('room_participants')
          .update({'room_color': color}).match({'room_id': roomId});
      _color = color;
      emit(ChatLoaded(
        _messages,
        _color,
      ));
    } catch (_) {
      emit(
        ChatError(
          'Error saving new color',
        ),
      );
    }
  }

  void setMessagesListener(String roomId, int color) async {
    _roomId = roomId;
    _myUserId = supabase.auth.currentUser!.id;
    _color = color;
    _messagesSubscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map<List<Message>>(
          (data) => data
              .map<Message>(
                (row) => Message.fromMap(
                  map: row,
                  myUserId: _myUserId,
                  contentDecrypted: row['is_text'].toString() == 'true'
                      ? decryptedAES(
                          row['content'],
                        )
                      : row['content'],
                ),
              )
              .toList(),
        )
        .listen((messages) {
          _messages = messages;
          if (_messages.isEmpty) {
            emit(ChatEmpty(_color));
          } else {
            emit(
              ChatLoaded(
                _messages,
                _color,
              ),
            );
          }
        });
  }

  Future<void> sendMessage(String text) async {
    final content = encryptedAES(text);
    final messageSupa = Message(
      id: 'new',
      roomId: _roomId,
      profileId: _myUserId,
      content: content,
      createdAt: DateTime.now(),
      isMine: true,
      isText: true,
      isVideo: false,
    );
    final message = Message(
      id: 'new',
      roomId: _roomId,
      profileId: _myUserId,
      content: text,
      createdAt: DateTime.now(),
      isMine: true,
      isText: true,
      isVideo: false,
    );

    _messages.insert(0, message);
    emit(ChatLoaded(
      _messages,
      _color,
    ));
    try {
      await supabase.from('messages').insert(messageSupa.toMap());
      await supabase.from('room_participants').update({
        'last_message': messageSupa.content,
        'message_time': messageSupa.createdAt.toUtc().toIso8601String()
      }).match(
        {'room_id': _roomId},
      );
    } catch (e) {
      emit(
        ChatError(
          'Error submitting message: $e',
        ),
      );
      _messages.removeWhere((message) => message.id == 'new');
      emit(
        ChatLoaded(
          _messages,
          _color,
        ),
      );
    }
  }

  Future<void> deleteMessage(String id) async {
    final message = _messages.firstWhere((element) => element.id == id);
    final isText = message.isText;
    String filePath = '';
    if (!isText) {
      filePath = message.content;
    }
    final index = _messages.indexOf(message);
    _messages.removeAt(index);
    final lastMessage = _messages.first;
    final lastMessageUpdate = Message(
      id: 'new',
      roomId: lastMessage.roomId,
      profileId: lastMessage.profileId,
      content: lastMessage.content,
      createdAt: lastMessage.createdAt,
      isMine: lastMessage.isMine,
      isText: lastMessage.isText,
      isVideo: lastMessage.isVideo,
    );
    _messages.removeAt(0);
    _messages.insert(0, lastMessageUpdate);
    emit(ChatLoaded(
      _messages,
      _color,
    ));
    try {
      final rawMap =
          await supabase.from('messages').select().eq('id', lastMessage.id);
      await supabase.from('messages').delete().eq('id', id);
      if (!isText) {
        await supabase.storage.from('chats').remove([
          filePath.substring(70, 135),
        ]);
      }
      final Map<String, dynamic> map = rawMap[0];
      final bool isTextNew = map['is_text'];
      final bool isVideo = map['is_video'];
      await supabase.from('room_participants').update({
        'last_message': isTextNew
            ? map['content']
            : !isVideo
                ? 'Image'
                : 'Video',
        'message_time': map['created_at'],
      }).match({
        'room_id': _roomId,
      });
    } on StorageException catch (error) {
      emit(
        ChatError(
          'Error deleting photo: ${error.message}',
        ),
      );
    } catch (e) {
      emit(ChatError('Error deleting message: $e'));
      final messages1 = _messages.sublist(0, index);
      final messages2 = _messages.sublist(index + 1, _messages.length);
      messages1.addAll(messages2);
      _messages = messages1;
      emit(
        ChatLoaded(
          _messages,
          _color,
        ),
      );
    }
  }

  void deleteChat(String roomId) async {
    try {
      await supabase.from('messages').delete().eq('id', roomId);
      final data = _messages.where(
        (element) => element.isText == false,
      );
      _messages.clear();
      if (data.isNotEmpty) {
        for (var media in data) {
          await supabase.storage.from('chats').remove([
            media.content.substring(70, 135),
          ]);
        }
      }
      emit(ChatEmpty(_color));
    } catch (_) {
      emit(
        ChatError(
          'Error deleting chat',
        ),
      );
    }
  }

  Future<void> sendPicture(
    Uint8List bytes,
    String filePath,
    String? contentType,
    bool isVideo,
  ) async {
    try {
      await supabase.storage.from('chats').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );
      final imageUrl = await supabase.storage
          .from('chats')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      final messageSupa = Message(
        id: 'new',
        roomId: _roomId,
        profileId: _myUserId,
        content: imageUrl,
        createdAt: DateTime.now(),
        isMine: true,
        isText: false,
        isVideo: isVideo,
      );
      final message = Message(
        id: 'new',
        roomId: _roomId,
        profileId: _myUserId,
        content: imageUrl,
        createdAt: DateTime.now(),
        isMine: true,
        isText: false,
        isVideo: isVideo,
      );
      _messages.insert(0, message);
      emit(
        ChatLoaded(
          _messages,
          _color,
        ),
      );
      await supabase.from('messages').insert(messageSupa.toMap());
      await supabase.from('room_participants').update(
        {
          'last_message': !isVideo ? 'Image' : 'Video',
          'message_time': messageSupa.createdAt.toUtc().toIso8601String()
        },
      ).match({'room_id': _roomId});
    } on StorageException catch (error) {
      emit(
        ChatError(
          'Error saving photo: ${error.message}',
        ),
      );
    } catch (error) {
      emit(
        ChatError(
          'Error submitting message $error',
        ),
      );
      _messages.removeWhere((message) => message.id == 'new');
      emit(
        ChatLoaded(
          _messages,
          _color,
        ),
      );
    }
  }

  Future<void> uploadGroupPhoto(
    Uint8List bytes,
    String filePath,
    String? contentType,
    String roomId,
    bool update,
    Map<String, dynamic> group,
  ) async {
    try {
      String imageUrl = '';
      if (update) {
        await supabase.storage.from('groups').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                contentType: contentType,
              ),
            );
        imageUrl = await supabase.storage
            .from('groups')
            .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      } else {
        final path = roomId;
        imageUrl = group['image'];
        await supabase.storage.from('groups').updateBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: contentType),
            );
      }
      group.update('image', (value) => imageUrl);
      await supabase
          .from('room_participants')
          .update({'group_info': group}).match({'room_id': roomId});
      emit(ChatLoaded(
        _messages,
        _color,
      ));
    } on StorageException catch (error) {
      emit(ChatError('Error saving photo: ${error.message}'));
    } catch (error) {
      emit(ChatError('Error uploading photo: $error'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _colorSubscription?.cancel();
    return super.close();
  }
}
