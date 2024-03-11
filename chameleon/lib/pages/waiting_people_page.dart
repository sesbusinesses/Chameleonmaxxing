import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'game_page.dart';
import '../widgets/utility.dart'; // Import utility for showMessage
import 'dart:async';

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
  late Stream<List<String>> playerNamesStream;
  late Stream<List<bool>> hasVotedStream;
  late Stream<bool> gameRunningStream;
  late StreamSubscription<bool> gameRunningSubscription;

  @override
  void initState() {
    super.initState();
    playerNamesStream = DatabaseManager.streamPlayerUsernames(widget.roomCode);
    hasVotedStream = DatabaseManager.streamVotingStatus(widget.roomCode);
    gameRunningStream = DatabaseManager.streamGameRunning(widget.roomCode);
    

    // Listen to the gameRunning stream
    gameRunningSubscription = gameRunningStream.listen((isGameRunning) {
      if (isGameRunning) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GamePage(
              roomCode: widget.roomCode,
              playerId: widget.playerId,
            ),
          ),
        );
      }
    });
  }

  //idk really what this dispose does.
  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    gameRunningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<String>>(
        stream: playerNamesStream,
        builder: (context, playerSnapshot) {
          if (playerSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (playerSnapshot.hasError) {
            return Text('Error: ${playerSnapshot.error}');
          } else if (playerSnapshot.hasData) {
            final List<String> playerNames = playerSnapshot.data!;
            return StreamBuilder<List<bool>>(
              stream: hasVotedStream,
              builder: (context, hasVotedSnapshot) {
                if (hasVotedSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (hasVotedSnapshot.hasError) {
                  return Text('Error: ${hasVotedSnapshot.error}');
                } else if (hasVotedSnapshot.hasData) {
                  final List<bool> votingStatus = hasVotedSnapshot.data!;
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
                              () async {
                                await DatabaseManager.startGame(widget.roomCode);
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
                            var localContext = context;
                            try {
                              if (widget.isHost) {
                                await DatabaseManager.removeEntireRoom(widget.roomCode);
                              } else {
                                await DatabaseManager.removePlayerFromRoom(widget.roomCode, widget.playerId);
                              }
                              Navigator.pop(localContext);
                            } catch (e) {
                              showMessage(localContext, 'Error leaving the game. Please try again.');
                            }
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text('No voting data available');
                }
              },
            );
          } else {
            return const Text('No player data available');
          }
        },
      ),
    );
  }
}
