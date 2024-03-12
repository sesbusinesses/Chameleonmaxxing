import 'package:flutter/material.dart';
import 'game_page.dart';
import '../models/database_manager.dart';
import 'waiting_people_page.dart';
import 'waiting_topics_page.dart';
import 'dart:async';

class WaitingPage extends StatefulWidget {
  final bool isHost;
  final String roomCode;
  final String playerId;

  const WaitingPage({
    super.key,
    this.isHost = false,
    required this.roomCode,
    required this.playerId,
  });

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  late Stream<bool> gameRunningStream;
  late StreamSubscription<bool> gameRunningSubscription;

  @override
  void initState() {
    super.initState();
    gameRunningStream = DatabaseManager.streamGameRunning(widget.roomCode);

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

  @override
  void dispose() {
    gameRunningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Code: ${widget.roomCode}'), // Display roomCode in AppBar title
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          WaitingTopicsPage(roomCode: widget.roomCode, playerId: widget.playerId),
          WaitingPeoplePage(isHost: widget.isHost, roomCode: widget.roomCode, playerId: widget.playerId),
        ],
      ),
    );
  }
}