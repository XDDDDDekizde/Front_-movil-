class Room {
  final String id;
  final String name;
  final String type;

  Room({required this.id, required this.name, required this.type});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
    );
  }
}