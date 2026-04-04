import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await cargarUsuariosDesdeArchivo();
  } catch (e) {
    print("Error inicial: $e");
  }

  runApp(MyApp());
}

// ================= ARCHIVO =================

Future<File> _getFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/usuarios.json');
}

Future<void> cargarUsuariosDesdeArchivo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final file = await _getFile();

    if (await file.exists()) {
      String content = await file.readAsString();

      if (content.isNotEmpty) {
        try {
          jsonDecode(content);
          await prefs.setString('users', content);
        } catch (e) {
          print("JSON corrupto ignorado");
        }
      }
    }
  } catch (e) {
    print("Error cargando archivo: $e");
  }
}

Future<void> guardarUsuariosEnArchivo(Map<String, String> users) async {
  try {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(users));
  } catch (e) {
    print("Error guardando archivo: $e");
  }
}

// ================= APP =================

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}

// ================= LOGIN =================

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passController = TextEditingController();

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();

    String? usersJson = prefs.getString('users');

    Map<String, String> users = {};
    try {
      users = usersJson != null
          ? Map<String, String>.from(jsonDecode(usersJson))
          : {};
    } catch (e) {
      users = {};
    }

    String username = userController.text;
    String password = passController.text;

    if (!mounted) return; // 🔥 FIX

    if (users.containsKey(username) && users[username] == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(username: username),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario o contraseña incorrectos")),
      );
    }
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
            Text("Bienvenido", style: TextStyle(fontSize: 28)),
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
              onPressed: login,
              child: Text("Ingresar"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
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

// ================= REGISTRO =================

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

    Map<String, String> users = {};
    try {
      users = usersJson != null
          ? Map<String, String>.from(jsonDecode(usersJson))
          : {};
    } catch (e) {
      users = {};
    }

    String username = userController.text;
    String password = passController.text;

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    if (users.containsKey(username)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El usuario ya existe")),
      );
      return;
    }

    users[username] = password;

    await prefs.setString('users', jsonEncode(users));
    await guardarUsuariosEnArchivo(users);

    if (!mounted) return; // 🔥 FIX

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

// ================= HOME =================

class HomePage extends StatelessWidget {
  final String username;

  HomePage({required this.username});

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Center(
        child: Text(
          "Bienvenido $username 👋",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}