// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'game_page.dart';
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

  @override
  void initState() {
    super.initState();
    playerNamesStream = DatabaseManager.streamPlayerUsernames(widget.roomCode);
    hasVotedStream = DatabaseManager.streamVotingStatus(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<String>>(
        stream: playerNamesStream,
        builder: (context, playerSnapshot) {
          if (!playerSnapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final List<String> playerNames = playerSnapshot.data!;
          return StreamBuilder<List<bool>>(
            stream: hasVotedStream,
            builder: (context, hasVotedSnapshot) {
              if (!hasVotedSnapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final List<bool> votingStatus = hasVotedSnapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Waiting for Players',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: DisplayGrid(
                        userList: playerNames, hasVoted: votingStatus),
                  ),
                  if (widget.isHost)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: WideButton(
                        text: 'Start Game',
                        onPressed: () async {
                          await DatabaseManager.startGame(widget.roomCode);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GamePage(
                                    roomCode: widget.roomCode,
                                    playerId: widget.playerId)),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: WideButton(
                      text: 'Leave Game',
                      color: Colors.red,
                      onPressed: () async {
                        if (widget.isHost) {
                          await DatabaseManager.removeEntireRoom(
                              widget.roomCode);
                        } else {
                          await DatabaseManager.removePlayerFromRoom(
                              widget.roomCode, widget.playerId);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
