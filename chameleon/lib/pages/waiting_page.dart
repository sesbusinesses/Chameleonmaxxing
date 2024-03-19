import 'package:chameleon/widgets/swipe_more.dart';
import 'package:flutter/material.dart';
import 'game_page.dart';
import '../models/database_manager.dart';
import 'waiting_people_page.dart';
import 'waiting_topics_page.dart';
import '../widgets/utility.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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

class _WaitingPageState extends State<WaitingPage> with WidgetsBindingObserver{
  late Stream<bool> gameRunningStream;
  late StreamSubscription<bool> gameRunningSubscription;
  late Stream<bool> doesRoomExistStream;
  late StreamSubscription<bool> doesRoomExistSubscription;
  bool showSwipePrompt = true;
  final PageController _pageController = PageController();
  Timer? _kickoutTimer; // Timer for kicking out the player

  @override
  void initState() {
    super.initState();
    gameRunningStream = DatabaseManager.streamGameRunning(widget.roomCode);
    doesRoomExistStream = DatabaseManager.streamDoesRoomExist(widget.roomCode);
    WidgetsBinding.instance.addObserver(this);

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

    doesRoomExistSubscription = doesRoomExistStream.listen((doesGameExist) {
      if (!doesGameExist) {
        Navigator.popUntil(context, (route) => route.isFirst);
        if (!widget.isHost) {
          showMessage(context, 'The room no longer exists.');
        }
      }
    });
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
    gameRunningSubscription.cancel();
    doesRoomExistSubscription.cancel();
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Join Code: ${widget.roomCode}'),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (int page) {
                _hideSwipePrompt();
              },
              children: <Widget>[
                WaitingTopicsPage(
                    roomCode: widget.roomCode, playerId: widget.playerId),
                WaitingPeoplePage(
                    isHost: widget.isHost,
                    roomCode: widget.roomCode,
                    playerId: widget.playerId),
              ],
            ),
            if (showSwipePrompt)
              const Positioned(
                bottom: 200,
                left: 0,
                right: 0,
                child: FloatingText(),
              ),
          ],
        ),
      ),
    );
  }
}
