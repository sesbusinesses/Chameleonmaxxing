import 'package:flutter/material.dart';
import 'game_topic_page.dart';
import 'game_people_page.dart';

class GamePage extends StatelessWidget {
  final String roomCode; // Example data that might be passed to child pages
  final String playerId;

  const GamePage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Page'),
        automaticallyImplyLeading: false, // Consider navigation implications
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GameTopicPage(), // Hypothetically passing roomCode
          GamePeoplePage(
              playerId: playerId,
              roomCode: roomCode), // Passing both roomId and playerId
        ],
      ),
    );
  }
}
