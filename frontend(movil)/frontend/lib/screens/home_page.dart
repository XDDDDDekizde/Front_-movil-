import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatRoomController = TextEditingController();

  Future<void> logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bienvenido $username 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Conectado con el backend en http://localhost:8080",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "WebSocket: ws://localhost:3000",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: chatRoomController,
                decoration: InputDecoration(
                  labelText: "Nombre de la sala de chat",
                  border: OutlineInputBorder(),
                  hintText: "Ej: general, soporte, etc",
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (chatRoomController.text.trim().isNotEmpty) {
                  // Aquí irá la lógica para entrar a la sala de chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Entrando a sala: ${chatRoomController.text}"),
                    ),
                  );
                }
              },
              child: Text("Entrar a sala de chat"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    chatRoomController.dispose();
    super.dispose();
  }
}