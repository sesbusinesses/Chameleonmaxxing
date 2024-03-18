import 'package:flutter/material.dart';
import 'play_again_page.dart';
import 'leaderboard_page.dart';
import '../models/database_manager.dart';
import '../widgets/utility.dart';
import 'dart:async';
import 'waiting_page.dart';

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
  late Stream<List<bool>> runGameAgainStream;
  late StreamSubscription<List<bool>> runGameAgainSubscription;
  late Stream<bool> doesRoomExistStream;
  late StreamSubscription<bool> doesRoomExistSubscription;
  bool host = false; // Add the host variable

  @override
  void initState() {
    super.initState();

    // Determine if the current player is the host
    _checkIfHost();

    runGameAgainStream = DatabaseManager.streamPlayAgainStatus(widget.roomCode);
    doesRoomExistStream = DatabaseManager.streamDoesRoomExist(widget.roomCode);

    runGameAgainSubscription = runGameAgainStream.listen((List<bool> playersReadyList) {
      final allPlayersReady = playersReadyList.every((isReady) => isReady);
      if (allPlayersReady) {
        // Execute async code inside microtask
        Future.microtask(() async {
          // Perform necessary async operations before navigating
          await DatabaseManager.resetToPlayAgain(widget.roomCode);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WaitingPage(
                isHost: host, // Use the 'host' variable
                roomCode: widget.roomCode,
                playerId: widget.playerId,
              ),
            ),
          );
        });
      }
    });

    doesRoomExistSubscription = doesRoomExistStream.listen((doesGameExist) {
      if (!doesGameExist) {
        Navigator.popUntil(context, (route) => route.isFirst);
        showMessageWarning(context, 'The room no longer exists.');
      }
    });
  }

  Future<void> _checkIfHost() async {
    bool isHost = await DatabaseManager.isHost(widget.roomCode, widget.playerId);
    setState(() {
      host = isHost; // Set the host status based on the result
    });
  }

  @override
  void dispose() {
    runGameAgainSubscription.cancel();
    doesRoomExistSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
      )
    );
  }
}
