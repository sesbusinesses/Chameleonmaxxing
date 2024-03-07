import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/wide_button.dart';
import '../widgets/text_box.dart';
import 'waiting_page.dart';
import '../widgets/utility.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  final TextEditingController _nameController = TextEditingController();

  void _tryJoinGame() async {
    String roomCode = _nameController.text.trim();
    roomCode = roomCode.toUpperCase();
    if (roomCode.isEmpty) {
      showMessage(context,'Join code cannot be empty');
      return;
    }

    // Check if the room exists before attempting to join
    var roomExists = await DatabaseManager.doesRoomExist(roomCode);
    if (!roomExists) {
      showMessage(context,'Room does not exist');
      return;
    }

    // If the room exists, attempt to add the player
    try {
      String playerId = DatabaseManager.generateCode();
      await DatabaseManager.addPlayerToRoom(roomCode, playerId); // Use actual logic to generate/get player ID
      // Navigate to WaitingPage if adding is successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WaitingPage(roomCode: roomCode, playerId: playerId)),
      );
    } catch (e) {
      // Handle any errors during the process
      showMessage(context,'An error occurred while trying to join the room');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextBox(
              hintText: 'Enter join code',
              controller: _nameController,
            ),
            WideButton(
              text: 'Join Game',
              onPressed: _tryJoinGame,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: WideButton(
          text: 'Cancel',
          color: Colors.red,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
