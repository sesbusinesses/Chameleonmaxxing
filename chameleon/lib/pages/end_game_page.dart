import 'package:flutter/material.dart';
import 'play_again_page.dart'; // Make sure to import your PlayAgainPage
import 'leaderboard_page.dart'; // Make sure to import your LeaderboardPage

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        children: <Widget>[
          PlayAgainPage(roomCode: widget.roomCode, playerId: widget.playerId),
          LeaderboardPage(roomCode: widget.roomCode, playerId: widget.playerId),
        ],
      ),
    );
  }
}
