import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/wide_button.dart';
import '../widgets/text_box.dart';
import 'waiting_page.dart';
import '../widgets/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  final TextEditingController _gameCodeController = TextEditingController();
  String _username = ''; // Store the fetched username here

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';
    setState(() {
      _username = username; // Set the fetched username
    });
  }

  void _tryJoinGame() async {
    String roomCode = _gameCodeController.text.trim().toUpperCase();
    if (roomCode.isEmpty) {
      showMessage(context, 'Join code cannot be empty');
      return;
    }

    // Check if the room exists before attempting to join
    bool roomExists = await DatabaseManager.doesRoomExist(roomCode);
    if (!roomExists) {
      showMessage(context, 'Room does not exist');
      return;
    }

    // Check if the game is already running
    bool gameRunning = await DatabaseManager.streamGameRunning(roomCode).first;
    if (gameRunning) {
      showMessage(context, 'Cannot join, the game is already running');
      return;
    }

    // If the room exists, attempt to add the player with detailed information
    try {
      String playerId = DatabaseManager.generateCode();
      // Adjust the addPlayerToRoom method to include the player's detailed information
      await DatabaseManager.addPlayerToRoom(roomCode, playerId, _username);
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
    return PopScope(
      canPop: false,
      child: Scaffold(
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
              WideButton(
                text: 'Join Game',
                onPressed: _tryJoinGame,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: WideButton(
            text: 'Cancel',
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    _gameCodeController.dispose();
    super.dispose();
  }
}
