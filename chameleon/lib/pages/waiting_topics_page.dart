import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/selectable_grid.dart';

class WaitingTopicsPage extends StatelessWidget {
  final String playerId;
  final String roomCode;

  const WaitingTopicsPage({
    super.key,
    required this.playerId,
    required this.roomCode,
  });

  @override
  Widget build(BuildContext context) {
    // Topics could be dynamically fetched or updated based on your app's requirements
    List<String> topics = const ['topic1', 'topic2', 'topic3', 'topic4'];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Choose a Topic',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              // Wrap SelectableGrid with Expanded to use available space
              child: SelectableGrid(
                displayList: topics,
                color: Colors.grey,
                updateField: 'votingTopic',
                roomCode: roomCode,
                playerId: playerId,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
