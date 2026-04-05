import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class RoomService {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<List<Room>> getRooms() async {
    final response = await http.get(
      Uri.parse("$baseUrl/rooms"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Room.fromJson(e)).toList();
    }
    return [];
  }

  Future<Room?> createRoom(
      String name,
      String type,
      String userId,
      ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/rooms"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "type": type,
        "created_by": userId,
      }),
    );

    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}