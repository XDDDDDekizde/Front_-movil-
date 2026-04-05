import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/room.dart';
import '../services/room_service.dart';
import 'chat_screen.dart';

class RoomsScreen extends StatefulWidget {
  final User user;

  const RoomsScreen({super.key, required this.user});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final roomService = RoomService();
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  void loadRooms() async {
    rooms = await roomService.getRooms();
    setState(() {});
  }

  void createRoom() async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva sala"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              Room? room = await roomService.createRoom(
                controller.text,
                "public",
                widget.user.id,
              );

              if (room != null) {
                rooms.add(room);
                setState(() {});
              }

              Navigator.pop(context);
            },
            child: const Text("Crear"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text("Salas - ${widget.user.username}")),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (_, i) {
          final room = rooms[i];

          return ListTile(
            title: Text(room.name),
            subtitle: Text(room.type),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    user: widget.user,
                    room: room,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createRoom,
        child: const Icon(Icons.add),
      ),
    );
  }
}