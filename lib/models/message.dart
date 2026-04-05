class Message {
  final String id;
  final String roomId;
  final String userId;
  final String content;

  Message({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      roomId: json['room_id'].toString(),
      userId: json['user_id'].toString(),
      content: json['content'],
    );
  }
}