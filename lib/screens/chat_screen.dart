import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  final Room room;

  const ChatScreen({
    super.key,
    required this.user,
    required this.room,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageService = MessageService();
  final controller = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  void loadMessages() async {
    messages =
    await messageService.getMessages(widget.room.id);
    setState(() {});
  }

  void sendMessage() async {
    if (controller.text.isEmpty) return;

    await messageService.sendMessage(
      widget.room.id,
      widget.user.id,
      controller.text,
    );

    controller.clear();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.room.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];

                return MessageBubble(
                  message: msg,
                  isMe: msg.userId == widget.user.id,
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: controller),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}