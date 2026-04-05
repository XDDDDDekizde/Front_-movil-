import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageService {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<List<Message>> getMessages(String roomId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/messages/$roomId"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Message.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> sendMessage(
      String roomId,
      String userId,
      String content,
      ) async {
    await http.post(
      Uri.parse("$baseUrl/messages"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "room_id": roomId,
        "user_id": userId,
        "content": content,
      }),
    );
  }
}