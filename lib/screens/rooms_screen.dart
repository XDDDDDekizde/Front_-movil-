import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'chat_screen.dart';

class RoomsScreen extends StatefulWidget {
  final User user;

  const RoomsScreen({super.key, required this.user});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final AuthService authService = AuthService();
  final TextEditingController roomController = TextEditingController();

  List rooms = [];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  void loadRooms() async {
    var data = await authService.getRooms();
    setState(() {
      rooms = data;
    });
  }

  void createRoom() async {
    if (roomController.text.isEmpty) return;

    await authService.createRoom(
      roomController.text,
      widget.user.id,
    );

    roomController.clear();
    loadRooms();
  }

  void openRoom(room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          room: room,
          user: widget.user,
        ),
      ),
    );
  }

  void showOptions(room) {
    bool isOwner = room['created_by'] == widget.user.id;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner)
                ListTile(
                  title: const Text("Eliminar sala",
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);

                    await authService.deleteRoom(
                      room['id'],
                      widget.user.id,
                    );

                    loadRooms();
                  },
                ),
              ListTile(
                title: const Text("Cerrar"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Salas - ${widget.user.username}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: roomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Nombre de sala",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: createRoom,
                  icon: const Icon(Icons.add, color: Colors.white),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                var room = rooms[index];

                return ListTile(
                  title: Text(
                    room['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => openRoom(room),
                  onLongPress: () => showOptions(room), // 🔥 aquí
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}