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
<<<<<<< HEAD
=======
      appBar: AppBar(
        title: const Text('Vote for the Chameleon'),
        automaticallyImplyLeading: false,
      ),
>>>>>>> 63adb8ee226f5b023a8f0d5139bde530f6f230e5
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: DatabaseManager.streamVoteNum(roomCode),
            builder: (context, voteSnapshot) {
              if (voteSnapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
<<<<<<< HEAD
                    '${voteSnapshot.data} People Have Voted for the Alien',
=======
                    '${voteSnapshot.data} People Have Voted',
>>>>>>> 63adb8ee226f5b023a8f0d5139bde530f6f230e5
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
