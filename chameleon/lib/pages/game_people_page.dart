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
      body: Center(
        child: FutureBuilder<List<String>>(
          future: DatabaseManager.getPlayerUsernames(roomCode),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              // Adjust the layout to be similar to WaitingTopicsPage
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text(
                    'Choose a Player',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SelectableGrid(
                    displayList: snapshot.data!,
                    color: Colors.grey,
                    updateField: 'votingCham',
                    onSelectionConfirmed: (selectedPlayer) {
                      // Assuming a method to update player voting status
                      DatabaseManager.setPlayerVotingCham(
                              roomCode, playerId, selectedPlayer)
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('You voted for "$selectedPlayer"')),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating your vote')),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              );
            } else {
              return const Text('No players found');
            }
          },
        ),
      ),
    );
  }
}
