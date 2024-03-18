import 'package:flutter/material.dart';
import 'play_again_page.dart'; // Make sure to import your PlayAgainPage
import 'leaderboard_page.dart'; // Make sure to import your LeaderboardPage
import '../models/database_manager.dart';
import '../widgets/utility.dart';
import 'dart:async';

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
  //late Stream<bool> gameRunningStream;
  //late StreamSubscription<bool> gameRunningSubscription;
  late Stream<bool> doesRoomExistStream;
  late StreamSubscription<bool> doesRoomExistSubscription;
  
  @override
  void initState() {
    super.initState();
    
    //gameRunningStream = DatabaseManager.streamGameRunning(widget.roomCode);
    doesRoomExistStream = DatabaseManager.streamDoesRoomExist(widget.roomCode);

    /*
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
    */

    doesRoomExistStream = DatabaseManager.streamDoesRoomExist(widget.roomCode);
    doesRoomExistSubscription = doesRoomExistStream.listen((doesGameExist) {
      if (!doesGameExist) {
        Navigator.popUntil(context, (route) => route.isFirst);
        showMessageWarning(context, 'The room no longer exists.');
      }
    });
  }

  @override
  void dispose() {
    //gameRunningSubscription.cancel();
    doesRoomExistSubscription.cancel();
    super.dispose();
  }


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
