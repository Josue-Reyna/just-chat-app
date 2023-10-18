import 'package:just_chat_app/models/group.dart';
import 'package:just_chat_app/services/encryption_service.dart';

// Room Model

class Room {
  Room({
    required this.id,
    required this.createdAt,
    required this.otherUserId,
    required this.lastMessage,
    required this.messageTime,
    required this.color,
    required this.group,
  });

  final String id;

  final DateTime createdAt;

  final String? otherUserId;
  final int color;

  final String? lastMessage;
  final DateTime? messageTime;
  final Group? group;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  Room.fromRoomParticipants(Map<String, dynamic> map)
      : id = map['room_id'],
        otherUserId = map['profile_id'],
        createdAt = DateTime.parse(map['created_at']),
        lastMessage = map['last_message'] == null
            ? null
            : map['last_message'] == 'Image'
                ? map['last_message']
                : map['last_message'] == 'Video'
                    ? map['last_message']
                    : decryptedAES(
                        map['last_message'],
                      ),
        messageTime = map['message_time'] == null
            ? null
            : DateTime.parse(map['message_time']),
        color = map['room_color'],
        group = map['group_info'] == null
            ? null
            : Group.fromMap(
                map['group_info'],
              );

  Room copyWith({
    String? id,
    DateTime? createdAt,
    String? otherUserId,
    String? lastMessage,
    DateTime? messageTime,
    int? color,
    Group? group,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      otherUserId: otherUserId ?? this.otherUserId,
      lastMessage: lastMessage ?? this.lastMessage,
      messageTime: messageTime ?? this.messageTime,
      color: color ?? this.color,
      group: group ?? this.group,
    );
  }
}
