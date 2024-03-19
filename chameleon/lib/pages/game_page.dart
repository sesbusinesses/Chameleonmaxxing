import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/database_manager.dart';
import '../widgets/swipe_more.dart';
import 'end_game_page.dart';
import 'game_topic_page.dart';
import 'game_people_page.dart';
import 'cham_guess_page.dart'; // Import the ChamGuessPage

class GamePage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const GamePage({super.key, required this.roomCode, required this.playerId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver{
  late Stream<bool> voteNumStream;
  late StreamSubscription<bool> voteNumSubscription;
  bool isChameleon =
      false; // Initialize a flag to check if the player is the chameleon
  bool showSwipePrompt = true;
  Timer? _kickoutTimer; // Timer for kicking out the player

  @override
  void initState() {
    super.initState();
    voteNumStream = DatabaseManager.getVoteNumStream(widget.roomCode);
    WidgetsBinding.instance.addObserver(this);

    // Listen for changes in the voteNum to determine when to navigate to the EndGamePage.
    voteNumSubscription = voteNumStream.listen((voteNum) async {
      // Make this callback async
      if (voteNum) {
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
      }
    });

    // Immediately check if the current player is the chameleon and update the isChameleon flag accordingly.
    _checkIfChameleon();
  }

  Future<void> _checkIfChameleon() async {
    isChameleon = await DatabaseManager.isPlayerTheChameleon(
        widget.roomCode, widget.playerId);
    setState(() {}); // Update the UI after checking
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showSwipePrompt =
          (prefs.getBool('hasVisitedWaitingPage') ?? false) == false;
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
    voteNumSubscription.cancel(); // Make sure to cancel the subscription on dispose
    _kickoutTimer?.cancel(); // Cancel the timer if it's active
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Start a timer to remove the player if they don't return in time
      print("timer started");
      _kickoutTimer = Timer(Duration(minutes: 1), () {
        print("you are kicked out");
        DatabaseManager.removePlayerFromRoom(widget.roomCode, widget.playerId);
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } else if (state == AppLifecycleState.resumed) {
      // Cancel the timer if the player returns to the app
      _kickoutTimer?.cancel();
      print("timer canceled");
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
              bottom: 200,
              left: 0,
              right: 0,
              child: FloatingText(),
            ),
        ]))));
  }
}
