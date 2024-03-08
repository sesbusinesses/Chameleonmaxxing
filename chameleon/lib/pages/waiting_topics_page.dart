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
    return Center(
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
          SelectableGrid(
            displayList: ['topic1', 'topic2', 'topic3', 'topic4'],
            color: Colors.grey,
            updateField: 'votingTopic',
            onSelectionConfirmed: (selectedTopic) {
              DatabaseManager.setPlayerVotingTopic(
                      roomCode, playerId, selectedTopic)
                  .then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You selected "$selectedTopic"')),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating your choice')),
                );
              });
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
