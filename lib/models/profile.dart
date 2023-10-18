// Profile Model

class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.imageUrl,
    required this.color,
    required this.status,
    required this.bio,
  });

  final String id;

  final String username;

  final DateTime createdAt;

  int color;
  String? imageUrl;
  bool status;
  final String? bio;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'avatar_url': imageUrl,
      'color': color,
    };
  }

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        imageUrl = map['avatar_url'],
        color = map['color'].toInt(),
        status = map['status'],
        bio = map['bio'];

  Profile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? imageUrl,
    int? color,
    bool? status,
    String? bio,
  }) {
    return Profile(
      id: id ?? this.id,
      username: name ?? username,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      status: status ?? this.status,
      bio: bio ?? this.bio,
    );
  }
}
