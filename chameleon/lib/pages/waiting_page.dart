import 'package:flutter/material.dart';

import 'waiting_people_page.dart';
import 'waiting_topics_page.dart';

class WaitingPage extends StatelessWidget {
  final bool isHost;
  final String roomCode; // Add roomCode as a required parameter
  final String playerId;

  // Update constructor to include roomCode
   const WaitingPage({super.key, this.isHost = false, required this.roomCode, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Code: $roomCode'), // Use roomCode in AppBar title
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          WaitingPeoplePage(isHost: isHost, roomCode: roomCode,playerId: playerId), // No change needed here
           const WaitingTopicsPage(), // No changes needed here
        ],
      ),
    );
  }
}
