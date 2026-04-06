import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl = "http://localhost:8080/api";

  Future<User?> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }

    print(response.body);
    return null;
  }

  Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    print("LOGIN RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<List> getRooms() async {
    final response = await http.get(Uri.parse("$baseUrl/rooms"));
    return jsonDecode(response.body);
  }

  Future createRoom(String name, String userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/rooms"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "type": "public",
        "created_by": userId,
      }),
    );

    print("CREATE ROOM: ${response.body}");
  }

  // 🔥 NUEVO: eliminar sala
  Future deleteRoom(String roomId, String userId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/rooms"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "room_id": roomId,
        "user_id": userId,
      }),
    );

    print("DELETE ROOM: ${response.body}");
  }

  Future sendMessage(
    String roomId,
    String userId,
    String text,
  ) async {
    await http.post(
      Uri.parse("$baseUrl/messages"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "room_id": roomId,
        "user_id": userId,
        "content": text,
      }),
    );
  }

  Future<List> getMessages(String roomId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/messages?room_id=$roomId"));
    return jsonDecode(response.body);
  }
}