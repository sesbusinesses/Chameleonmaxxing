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
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: DatabaseManager.streamVoteNum(roomCode),
            builder: (context, voteSnapshot) {
              if (voteSnapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '${voteSnapshot.data} People Voted for the Alien',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Waiting for votes...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: DatabaseManager.getPlayerUsernames(roomCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return SelectableGrid(
                    displayList: snapshot.data!,
                    color: Colors.grey,
                    updateField: 'votingCham',
                    roomCode: roomCode,
                    playerId: playerId,
                  );
                } else {
                  return const Center(child: Text('No players found'));
                }
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
