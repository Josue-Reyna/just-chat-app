// Group Model

class Group {
  Group({
    required this.name,
    required this.image,
    required this.members,
    required this.creator,
    required this.groupBio,
  });

  final String name;
  final String? image;
  final int members;
  final String creator;
  final String groupBio;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'members': members,
      'creator': creator,
      'group_bio': groupBio,
    };
  }

  Group.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        image = map['image'],
        members = map['members'],
        creator = map['creator'],
        groupBio = map['group_bio'];
}
