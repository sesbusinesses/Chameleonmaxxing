import 'package:flutter/material.dart';
import '../models/database_manager.dart';

class RevealPage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const RevealPage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  State<RevealPage> createState() => _RevealPageState();
}

class _RevealPageState extends State<RevealPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Game Ended',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // This adds space between the text and the button
            ElevatedButton(
              onPressed: () {
                // Pop the current route off the stack
                DatabaseManager.removeEntireRoom(widget.roomCode);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Leave Game'),
            ),
          ],
        ),
      ),
    );
  }
}
