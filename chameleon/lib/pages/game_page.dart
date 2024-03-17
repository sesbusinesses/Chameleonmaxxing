import 'package:flutter/material.dart';
import 'dart:async';
import '../models/database_manager.dart';
import 'game_topic_page.dart';
import 'game_people_page.dart';
import 'endgame_page.dart';

class GamePage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const GamePage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Stream<bool> voteNumStream;
  late StreamSubscription<bool> voteNumSubscription;

  @override
  void initState() {
    super.initState();
    voteNumStream = DatabaseManager.getVoteNumStream(widget.roomCode);

    voteNumSubscription = voteNumStream.listen((voteNum) {
      //int countPlayersInRoom = await DatabaseManager.countPlayersInRoom(widget.roomCode); // Retrieve the player count asynchronously
      if (voteNum) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EndGamePage(roomCode: widget.roomCode),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    voteNumSubscription
        .cancel(); // Corrected to the proper subscription variable
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Page'),
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GameTopicPage(
              roomCode: widget.roomCode,
              playerId:
                  widget.playerId), // Use 'widget.' to access widget properties
          GamePeoplePage(roomCode: widget.roomCode, playerId: widget.playerId),
        ],
      ),
    );
  }
}
