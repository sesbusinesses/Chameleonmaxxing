import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'game_page.dart';
import '../widgets/utility.dart';

class WaitingPeoplePage extends StatefulWidget {
  final bool isHost;
  final String roomCode;
  final String playerId;

  const WaitingPeoplePage({
    super.key,
    required this.isHost,
    required this.roomCode,
    required this.playerId,
  });

  @override
  State<WaitingPeoplePage> createState() => _WaitingPeoplePageState();
}

class _WaitingPeoplePageState extends State<WaitingPeoplePage> {
  List<String> players = []; // This will hold the list of player IDs

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  void fetchPlayers() async {
    var playerIds = await DatabaseManager.getPlayersInRoom(widget.roomCode);
    if (mounted) {
      setState(() {
        players = playerIds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Waiting for Players',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Expanded(
              // Make DisplayGrid flexible within the column
              child: DisplayGrid(
                userList: players, // Use fetched player IDs
                hasVoted: List<bool>.filled(
                    players.length, false), // Example, adjust as necessary
              ),
            ),
            if (widget.isHost)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: WideButton(
                  text: 'Start Game',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GamePage()));
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: WideButton(
                text: 'Leave Game',
                color: Colors.red,
                onPressed: () async {
                  try {
                    if (widget.isHost) {
                      await DatabaseManager.removeEntireRoom(widget.roomCode);
                    } else {
                      await DatabaseManager.removePlayerFromRoom(
                          widget.roomCode, widget.playerId);
                    }
                    Navigator.pop(context); // Navigate back to previous screen
                  } catch (e) {
                    showMessage(
                        context, 'Error leaving the game. Please try again.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
