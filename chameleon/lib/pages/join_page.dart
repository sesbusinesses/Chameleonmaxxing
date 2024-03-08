import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/wide_button.dart';
import '../widgets/text_box.dart';
import 'waiting_page.dart';
import '../widgets/utility.dart'; // Assuming this contains the showMessage function

class JoinPage extends StatefulWidget {
  const JoinPage({Key? key}) : super(key: key);

  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  final TextEditingController _gameCodeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  void _tryJoinGame() async {
    String roomCode = _gameCodeController.text.trim().toUpperCase();
    String username = _usernameController.text.trim();
    if (roomCode.isEmpty || username.isEmpty) {
      showMessage(context, 'Join code and username cannot be empty');
      return;
    }

    // Check if the room exists before attempting to join
    bool roomExists = await DatabaseManager.doesRoomExist(roomCode);
    if (!roomExists) {
      showMessage(context, 'Room does not exist');
      return;
    }

    // If the room exists, attempt to add the player with detailed information
    try {
      String playerId = DatabaseManager.generateCode();
      // Adjust the addPlayerToRoom method to include the player's detailed information
      await DatabaseManager.addPlayerToRoom(roomCode, playerId, username);
      // Navigate to WaitingPage if adding is successful
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WaitingPage(roomCode: roomCode, playerId: playerId)),
      );
    } catch (e) {
      // Handle any errors during the process
      showMessage(context, 'An error occurred while trying to join the room');
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
              controller: _gameCodeController,
            ),
            TextBox(
              hintText: 'Enter your username',
              controller: _usernameController,
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
    _gameCodeController.dispose();
    _usernameController.dispose(); // Ensure usernameController is also disposed
    super.dispose();
  }
}
