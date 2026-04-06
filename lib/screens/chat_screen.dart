import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ChatScreen extends StatefulWidget {
  final dynamic room;
  final User user;

  const ChatScreen({
    super.key,
    required this.room,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService authService = AuthService();
  final TextEditingController messageController = TextEditingController();

  List messages = [];

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  void loadMessages() async {
    try {
      var data = await authService.getMessages(widget.room['id']);

      setState(() {
        messages = data;
      });
    } catch (e) {
      print("Error cargando mensajes: $e");
    }
  }

  void sendMessage() async {
    if (messageController.text.isEmpty) return;

    await authService.sendMessage(
      widget.room['id'],
      widget.user.id,
      messageController.text,
    );

    messageController.clear();
    loadMessages();
  }

  Widget buildMessage(msg) {
    // 🔥 PROTECCIÓN TOTAL CONTRA NULL
    String content = msg['content'] ?? '';
    String userId = msg['user_id'] ?? '';
    String username = msg['user'] ?? 'Usuario';

    bool isMe = userId == widget.user.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              content,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.room['name'] ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Mensaje...",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}