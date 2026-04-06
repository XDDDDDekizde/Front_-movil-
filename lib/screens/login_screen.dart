import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'rooms_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();

  final authService = AuthService();

  void login() async {
    User? user = await authService.login(
      username.text,
      password.text,
    );

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Credenciales incorrectas")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomsScreen(user: user),
      ),
    );
  }

  void goRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login",
                style: TextStyle(color: Colors.white, fontSize: 24)),

            const SizedBox(height: 20),

            TextField(
              controller: username,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Usuario",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: password,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Contraseña",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text("Entrar"),
            ),

            TextButton(
              onPressed: goRegister,
              child: const Text("Crear cuenta"),
            )
          ],
        ),
      ),
    );
  }
}