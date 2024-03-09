import 'package:flutter/material.dart';

import 'waiting_people_page.dart';
import 'waiting_topics_page.dart';

class WaitingPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Code: $roomCode'), // Display roomCode in AppBar title
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          WaitingTopicsPage(roomCode: roomCode, playerId: playerId),
          WaitingPeoplePage(
              isHost: isHost, roomCode: roomCode, playerId: playerId),
          // Pass roomCode and playerId to WaitingTopicsPage as well
        ],
      ),
    );
  }
}
