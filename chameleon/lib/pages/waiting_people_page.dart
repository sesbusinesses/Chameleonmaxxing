import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'game_page.dart';
import '../widgets/utility.dart'; // Import utility for showMessage

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
  late Future<List<String>> playerNamesFuture;
  late Future<List<bool>> hasVotedFuture;

  @override
  void initState() {
    super.initState();
    playerNamesFuture = DatabaseManager.getPlayerUsernames(widget.roomCode);
    hasVotedFuture = DatabaseManager.getVotingTopicStatus(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Players'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([playerNamesFuture, hasVotedFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final List<String> playerNames = snapshot.data![0];
            final List<bool> votingStatus = snapshot.data![1];
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Text(
                  'Waiting for Players',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: DisplayGrid(
                    userList: playerNames,
                    hasVoted: votingStatus,
                  ),
                ),
                if (widget.isHost)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: WideButton(
                      text: 'Start Game',
                      onPressed: () {
                        // Use an anonymous async function to await the startGame call
                        () async {
                          await DatabaseManager.startGame(widget.roomCode);
                          // After starting the game, navigate to the GamePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GamePage(
                                roomCode: widget.roomCode,
                                playerId: widget.playerId,
                              ),
                            ),
                          );
                        }();
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: WideButton(
                    text: 'Leave Game',
                    color: Colors.red,
                    onPressed: () async {
                      // Use a local variable for context to avoid using BuildContext across async gaps
                      var localContext = context;
                      try {
                        if (widget.isHost) {
                          await DatabaseManager.removeEntireRoom(
                              widget.roomCode);
                        } else {
                          await DatabaseManager.removePlayerFromRoom(
                              widget.roomCode, widget.playerId);
                        }
                        Navigator.pop(localContext); // Use localContext here
                      } catch (e) {
                        showMessage(localContext,
                            'Error leaving the game. Please try again.'); // Use localContext here
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Text('No data available');
          }
        },
      ),
    );
  }
}
