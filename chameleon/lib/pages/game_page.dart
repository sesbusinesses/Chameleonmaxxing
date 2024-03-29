// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/database_manager.dart';
import '../widgets/swipe_more.dart';
import 'end_game_page.dart';
import 'game_topic_page.dart';
import 'game_people_page.dart';
import 'cham_guess_page.dart'; // Import the ChamGuessPage
import '../widgets/utility.dart';

class GamePage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const GamePage({super.key, required this.roomCode, required this.playerId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  late Stream<bool> voteNumStream;
  late StreamSubscription<bool> voteNumSubscription;
  late Stream<bool> doesRoomExistStream;
  late StreamSubscription<bool> doesRoomExistSubscription;
  bool isChameleon =
      false; // Initialize a flag to check if the player is the chameleon
  bool showSwipePrompt = true;
  Timer? _kickoutTimer; // Timer for kicking out the player

  @override
  void initState() {
    super.initState();
    voteNumStream = DatabaseManager.getVoteNumStream(widget.roomCode);
    doesRoomExistStream = DatabaseManager.streamDoesRoomExist(widget.roomCode);
    WidgetsBinding.instance.addObserver(this);
    checkFirstGame();

    // Listen for changes in the voteNum to determine when to navigate to the EndGamePage.
    voteNumSubscription = voteNumStream.listen((voteNum) async {
      // Make this callback async
      if (voteNum) {
        bool voteTie = await DatabaseManager.isThereTie(widget.roomCode);
        if (voteTie != true) {
          await DatabaseManager.endGame(
              widget.roomCode); // Wait for endGame to complete
          if (mounted) {
            // Check if the widget is still in the widget tree
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EndGamePage(
                      roomCode: widget.roomCode, playerId: widget.playerId)),
            );
          }
        } else {
          DatabaseManager.resetVoteNum(widget.roomCode);
          DatabaseManager.resetToRevote(widget.roomCode);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => GamePage(
                      roomCode: widget.roomCode, playerId: widget.playerId)));
          showMessage(context,
              'It seems like humans are not sure who the alien is. Everyone give another clue.');
        }
      }
    });

    // Immediately check if the current player is the chameleon and update the isChameleon flag accordingly.
    _checkIfChameleon();

    doesRoomExistSubscription = doesRoomExistStream.listen((doesGameExist) {
      if (!doesGameExist) {
        Navigator.popUntil(context, (route) => route.isFirst);
        showMessage(context, 'The room no longer exists');
      }
    });
  }

  void checkFirstGame() async {
    // Use DatabaseManager.isFirstGame and update showSwipePrompt state
    bool isFirstGame = await DatabaseManager.isFirstGame(widget.roomCode);
    setState(() {
      showSwipePrompt = isFirstGame;
    });
  }

  Future<void> _checkIfChameleon() async {
    isChameleon = await DatabaseManager.isPlayerTheChameleon(
        widget.roomCode, widget.playerId);
    setState(() {}); // Update the UI after checking
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
    voteNumSubscription.cancel();
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
      _kickoutTimer = Timer(const Duration(minutes: 100), () {
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
    // The PageView now conditionally includes the ChamGuessPage based on the isChameleon flag.
    List<Widget> pages = [
      GameTopicPage(roomCode: widget.roomCode, playerId: widget.playerId),
      GamePeoplePage(roomCode: widget.roomCode, playerId: widget.playerId),
    ];

    if (isChameleon) {
      pages.add(
          ChamGuessPage(roomCode: widget.roomCode, playerId: widget.playerId));
    }
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: SafeArea(
                child: Stack(children: [
          PageView(
            scrollDirection: Axis.horizontal,
            children: pages,
            onPageChanged: (int page) {
              if (page == pages.length - 1) {
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
