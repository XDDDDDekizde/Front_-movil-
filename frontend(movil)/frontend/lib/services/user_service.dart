import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        jsonDecode(content);
        await prefs.setString('users', content);
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