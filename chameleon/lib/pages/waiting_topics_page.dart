import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/selectable_grid.dart';
import '../helpers/list_fetcher.dart';

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
          FutureBuilder<List<String>>(
            future: fetchTopics(),
            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Once data is fetched, pass it to the SelectableGrid
                  return SelectableGrid(
                    displayList: snapshot.data!, // Use the fetched list of topics
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
                  );
                } else if (snapshot.hasError) {
                  // Handle errors
                  return Text('Error fetching topics: ${snapshot.error}');
                } else {
                  // No data
                  return Text('No topics found');
                }
              } else {
                // While data is loading
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
