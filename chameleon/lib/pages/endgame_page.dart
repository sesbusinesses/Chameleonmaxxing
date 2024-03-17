import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/wide_button.dart';

class EndGamePage extends StatefulWidget {
  final String roomCode;

  const EndGamePage({super.key, required this.roomCode});

  @override
  _EndGamePageState createState() => _EndGamePageState();
}

class _EndGamePageState extends State<EndGamePage> {
  String? chameleonPlayerId;
  bool? chameleonCaught;

  @override
  void initState() {
    super.initState();
    fetchGameResults();
  }

  void fetchGameResults() async {
    // Assuming DatabaseManager has methods to fetch who the chameleon was and whether they were caught.
    String? chameleonId =
        await DatabaseManager.getChameleonUsername(widget.roomCode);
    bool caught = await DatabaseManager.wasChameleonCaught(widget.roomCode);

    setState(() {
      chameleonPlayerId = chameleonId;
      chameleonCaught = caught;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              chameleonCaught == true
                  ? 'Chameleon was caught!'
                  : 'Chameleon escaped!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Chameleon was: $chameleonPlayerId',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              WideButton(
                text: 'Vote Play Again',
                onPressed: () {
                  // Navigate to game setup or lobby
                },
              ),
              const SizedBox(height: 20),
              WideButton(
                text: 'Exit',
                color: Colors.red,
                onPressed: () {
                  // Pop until reaching the first route on the stack, which is the title page
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          )),
    );
  }
}
