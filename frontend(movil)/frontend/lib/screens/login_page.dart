import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Completa todos los campos");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthService.login(email, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      final userData = result['data'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(username: userData['username']),
        ),
      );
    } else {
      _showSnackBar(result['error'] ?? 'Error en el login');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bienvenido", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            TextField(
              controller: emailController,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passController,
              enabled: !isLoading,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text("Ingresar"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      ),
              child: Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}