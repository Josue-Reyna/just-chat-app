// Message Model

class Message {
  Message({
    required this.id,
    required this.roomId,
    required this.profileId,
    required this.content,
    required this.createdAt,
    required this.isMine,
    required this.isText,
    required this.isVideo,
  });

  final String id;

  final String profileId;

  final String roomId;

  final String content;

  final DateTime createdAt;

  final bool isMine;

  final bool isText;
  final bool isVideo;

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'room_id': roomId,
      'content': content,
      'is_text': isText,
      'is_video': isVideo,
    };
  }

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
    required String contentDecrypted,
  })  : id = map['id'],
        roomId = map['room_id'],
        profileId = map['profile_id'],
        content = contentDecrypted,
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['profile_id'],
        isText = map['is_text'],
        isVideo = map['is_video'];

  Message copyWith({
    String? id,
    String? userId,
    String? roomId,
    String? text,
    DateTime? createdAt,
    bool? isMine,
    bool? isText,
    bool? isVideo,
  }) {
    return Message(
      id: id ?? this.id,
      profileId: userId ?? profileId,
      roomId: roomId ?? this.roomId,
      content: text ?? content,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      isText: isText ?? this.isText,
      isVideo: isVideo ?? this.isVideo,
    );
  }
}
