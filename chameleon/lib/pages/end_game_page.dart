// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/swipe_more.dart';
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
  EndGamePageState createState() => EndGamePageState();
}

class EndGamePageState extends State<EndGamePage> with WidgetsBindingObserver {
  late Stream<List<bool>> runGameAgainStream;
  late StreamSubscription<List<bool>> runGameAgainSubscription;
  late Stream<bool> doesRoomExistStream;
  late StreamSubscription<bool> doesRoomExistSubscription;
  bool host = false; // Add the host variable
  bool showSwipePrompt = true;
  Timer? _kickoutTimer; // Timer for kicking out the player

  @override
  void initState() {
    super.initState();

    // Determine if the current player is the host
    _checkIfHost();

    runGameAgainStream = DatabaseManager.streamPlayAgainStatus(widget.roomCode);
    doesRoomExistStream = DatabaseManager.streamDoesRoomExist(widget.roomCode);
    WidgetsBinding.instance.addObserver(this);

    runGameAgainSubscription =
        runGameAgainStream.listen((List<bool> playersReadyList) {
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
        showMessage(context, 'The room no longer exists');
      }
    });
  }

  Future<void> _checkIfHost() async {
    bool isHost =
        await DatabaseManager.isHost(widget.roomCode, widget.playerId);
    setState(() {
      host = isHost; // Set the host status based on the result
    });
  }

  void _hideSwipePrompt() {
    if (showSwipePrompt) {
      setState(() {
        showSwipePrompt = false;
      });
      _saveVisitStatus();
    }
  }

  Future<void> _saveVisitStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasVisitedWaitingPage', true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    runGameAgainSubscription.cancel();
    doesRoomExistSubscription.cancel();
    _kickoutTimer?.cancel(); // Cancel the timer if it's active
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Start a timer to remove the player if they don't return in time
      _kickoutTimer = Timer(const Duration(minutes: 1), () {
        DatabaseManager.removePlayerFromRoom(widget.roomCode, widget.playerId);
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } else if (state == AppLifecycleState.resumed) {
      // Cancel the timer if the player returns to the app
      _kickoutTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: SafeArea(
                child: Stack(children: [
          PageView(
            children: <Widget>[
              PlayAgainPage(
                  roomCode: widget.roomCode, playerId: widget.playerId),
              LeaderboardPage(
                  roomCode: widget.roomCode, playerId: widget.playerId),
            ],
            onPageChanged: (int index) {
              if (index == 1) {
                _hideSwipePrompt();
              }
            },
          ),
          if (showSwipePrompt)
            const Positioned(
              bottom: 390,
              left: 0,
              right: 0,
              child: FloatingText(),
            ),
        ]))));
  }
}
