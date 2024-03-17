import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'title_page.dart'; // Assume this is your app's title or home page

class EndGamePage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const EndGamePage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  _EndGamePageState createState() => _EndGamePageState();
}

class _EndGamePageState extends State<EndGamePage> {
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
      appBar: AppBar(
        title: const Text('Game Over'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<bool>(
              future: wasChameleonCaught,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(
                    snapshot.data == true
                        ? 'Chameleon was caught!'
                        : 'Chameleon escaped!',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: chameleonUsername,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Text('Chameleon was: ${snapshot.data}');
                } else {
                  return const Text('Loading chameleon identity...');
                }
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: playerScore,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text('Your score: ${snapshot.data}');
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
                // Ensure there's a corresponding StreamBuilder for playAgainStream
                return StreamBuilder<List<bool>>(
                  stream: playAgainStream,
                  builder: (context, playAgainSnapshot) {
                    if (playAgainSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!playAgainSnapshot.hasData) {
                      return const Text('Waiting for players\' decisions...');
                    }
                    // Assuming DisplayGrid can handle empty or null lists properly
                    return Expanded(
                        child: DisplayGrid(
                      userList: playerSnapshot.data!,
                      hasVoted: playAgainSnapshot
                          .data!, // Assuming hasVoted is analogous to wantsToPlayAgain
                    ));
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40),
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
              text: 'Exit',
              color: Colors.red,
              onPressed: () async {
                bool host = await isPlayerHost;
                if (host) {
                  await DatabaseManager.removeEntireRoom(widget.roomCode);
                } else {
                  await DatabaseManager.removePlayerFromRoom(
                      widget.roomCode, widget.playerId);
                }
                // Navigate back to the title/home page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const TitlePage()), // Assuming TitlePage is your app's entry page
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
