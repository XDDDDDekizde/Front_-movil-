import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userController = TextEditingController();
  final passController = TextEditingController();

  Future<void> register() async {
    final prefs = await SharedPreferences.getInstance();

    String? usersJson = prefs.getString('users');

    Map<String, String> users = usersJson != null
        ? Map<String, String>.from(jsonDecode(usersJson))
        : {};

    String username = userController.text;
    String password = passController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    if (users.containsKey(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El usuario ya existe")),
      );
      return;
    }

    users[username] = password;

    await prefs.setString('users', jsonEncode(users));
    await guardarUsuariosEnArchivo(users);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Usuario registrado correctamente")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Crear cuenta", style: TextStyle(fontSize: 28)),
            SizedBox(height: 30),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: "Usuario"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Contraseña"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: register,
              child: Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}