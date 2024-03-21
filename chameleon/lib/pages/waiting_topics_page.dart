import 'package:flutter/material.dart';
import '../widgets/selectable_grid.dart';
import '../models/database_manager.dart';

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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Choose a Topic',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              // Use FutureBuilder to dynamically fetch topics
              child: FutureBuilder<List<String>>(
                future: DatabaseManager.fetchTopics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      // Data is available, use it in SelectableGrid
                      return SelectableGrid(
                        displayList: snapshot.data!, // Use the fetched topics
                        updateField: 'votingTopic',
                        roomCode: roomCode,
                        playerId: playerId,
                      );
                    } else if (snapshot.hasError) {
                      // Handle errors
                      return Text('Error fetching topics: ${snapshot.error}');
                    } else {
                      // No data
                      return const Text('No topics found');
                    }
                  }
                  // While data is loading
                  return const CircularProgressIndicator();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
