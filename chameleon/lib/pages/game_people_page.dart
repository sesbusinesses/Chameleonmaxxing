import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/selectable_grid.dart';

class GamePeoplePage extends StatelessWidget {
  final String roomCode;
  final String playerId;

  const GamePeoplePage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Game: $roomCode'), // Display room code in AppBar title for reference
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<String>>(
        future: DatabaseManager.getPlayerUsernames(roomCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Vote for the Chameleon',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableGrid(
                    displayList: snapshot.data!,
                    color: Colors.grey,
                    updateField: 'votingCham',
                    roomCode: roomCode,
                    playerId: playerId,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          } else {
            return const Center(child: Text('No players found'));
          }
        },
      ),
    );
  }
}
