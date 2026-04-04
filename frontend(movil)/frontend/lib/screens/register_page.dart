import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool isLoading = false;

  Future<void> register() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passController.text.trim();
    String confirmPassword = confirmPassController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Completa todos los campos");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Las contraseñas no coinciden");
      return;
    }

    if (password.length < 6) {
      _showSnackBar("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthService.register(username, email, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      _showSnackBar("Cuenta registrada correctamente");
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      _showSnackBar(result['error'] ?? 'Error en el registro');
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
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text("Crear cuenta", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              TextField(
                controller: usernameController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: "Usuario",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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
              SizedBox(height: 20),
              TextField(
                controller: confirmPassController,
                enabled: !isLoading,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : register,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Registrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}