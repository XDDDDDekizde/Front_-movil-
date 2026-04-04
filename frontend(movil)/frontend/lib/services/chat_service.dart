import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatService {
  static const String wsUrl = 'ws://localhost:3000';
  
  WebSocketChannel? _channel;
  
  // Conectar al servidor WebSocket
  Future<void> connect(String username, String room) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Enviar información de conexión
      final connectMessage = {
        'type': 'message',
        'username': username,
        'room': room,
        'message': 'Se ha conectado',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel!.sink.add(jsonEncode(connectMessage));
    } catch (e) {
      print('Error conectando a WebSocket: $e');
      rethrow;
    }
  }

  // Stream para recibir mensajes
  Stream<dynamic> getMessages() {
    if (_channel == null) {
      throw Exception('WebSocket no conectado');
    }
    return _channel!.stream;
  }

  // Enviar mensaje
  void sendMessage(String username, String room, String message) {
    if (_channel == null) {
      throw Exception('WebSocket no conectado');
    }
    
    final data = {
      'type': 'message',
      'username': username,
      'room': room,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel!.sink.add(jsonEncode(data));
  }

  // Responder a un mensaje
  void replyMessage(String username, String room, String originalMessage, String reply) {
    if (_channel == null) {
      throw Exception('WebSocket no conectado');
    }
    
    final data = {
      'type': 'reply',
      'username': username,
      'room': room,
      'originalMessage': originalMessage,
      'reply': reply,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel!.sink.add(jsonEncode(data));
  }

  // Reenviar mensaje
  void forwardMessage(String username, String fromRoom, String toRoom, String message) {
    if (_channel == null) {
      throw Exception('WebSocket no conectado');
    }
    
    final data = {
      'type': 'forward',
      'username': username,
      'room': toRoom,
      'message': message,
      'fromRoom': fromRoom,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel!.sink.add(jsonEncode(data));
  }

  // Eliminar mensaje
  void deleteMessage(String username, String room, String messageId) {
    if (_channel == null) {
      throw Exception('WebSocket no conectado');
    }
    
    final data = {
      'type': 'delete',
      'username': username,
      'room': room,
      'messageId': messageId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel!.sink.add(jsonEncode(data));
  }

  // Desconectar
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  // Verificar si está conectado
  bool isConnected() {
    return _channel != null;
  }
}
