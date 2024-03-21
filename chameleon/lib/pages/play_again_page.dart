// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'title_page.dart'; // Assume this is your app's title or home page

class PlayAgainPage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const PlayAgainPage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  PlayAgainPageState createState() => PlayAgainPageState();
}

class PlayAgainPageState extends State<PlayAgainPage> {
  late Future<bool> wasChameleonCaught;
  late Future<int> playerScore;
  late Future<bool> isPlayerHost;
  late Future<String?> chameleonUsername;
  late Stream<List<String>> playerNamesStream;
  late Stream<List<bool>> playAgainStream;

  @override
  void initState() {
    super.initState();
    wasChameleonCaught = DatabaseManager.wasChameleonCaught(widget.roomCode);
    playerScore =
        DatabaseManager.getPlayerScore(widget.roomCode, widget.playerId);
    isPlayerHost = DatabaseManager.isHost(widget.roomCode, widget.playerId);
    chameleonUsername = DatabaseManager.getChameleonUsername(widget.roomCode);
    playerNamesStream = DatabaseManager.streamPlayerUsernames(widget.roomCode);
    playAgainStream = DatabaseManager.streamPlayAgainStatus(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Combined FutureBuilder from here
            FutureBuilder<List<dynamic>>(
              future: Future.wait([wasChameleonCaught, chameleonUsername]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final wasCaught = snapshot.data?[0] ?? false;
                  final username = snapshot.data?[1];
                  return Column(
                    children: [
                      //make this text always centered.
                      Text(
                        wasCaught ? 'Alien $username was caught!' : 'Alien $username escaped!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            // to here
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: DatabaseManager.getTopicWord(widget.roomCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text('Secret Word: ${snapshot.data}');
                  } else {
                    return const Text('No topic word found');
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<String>>(
              stream: playerNamesStream,
              builder: (context, playerSnapshot) {
                if (playerSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!playerSnapshot.hasData) {
                  return const Text('No player data available');
                }
                return StreamBuilder<List<bool>>(
                  stream: playAgainStream,
                  builder: (context, playAgainSnapshot) {
                    if (playAgainSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!playAgainSnapshot.hasData) {
                      return const Text('Waiting for players\' decisions...');
                    }
                    return Expanded(
                      child: DisplayGrid(
                        userList: playerSnapshot.data!,
                        hasVoted: playAgainSnapshot.data!,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            WideButton(
              text: 'Play Again',
              color: Colors.green,
              onPressed: () {
                DatabaseManager.votePlayAgain(widget.roomCode, widget.playerId);
              },
            ),
            const SizedBox(height: 15),
            WideButton(
              text: 'Leave Game',
              color: Colors.red,
              onPressed: () async {
                bool host = await isPlayerHost;
                if (host) {
                  await DatabaseManager.removeEntireRoom(widget.roomCode);
                } else {
                  await DatabaseManager.removePlayerFromRoom(widget.roomCode, widget.playerId);
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const TitlePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}