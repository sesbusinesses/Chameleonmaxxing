import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';
import 'game_page.dart';

class WaitingPeoplePage extends StatelessWidget {
  final bool isHost; // Correctly declare as final

  // Correct constructor to initialize isHost
  const WaitingPeoplePage({super.key, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Text(
            'Waiting for Players',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          DisplayGrid(
            userList: const ['Player1', 'Player2', 'Player3', 'Player4'], // Example usernames
            hasVoted: const [true, false, true, false], // Example boolean values
          ),
          if (isHost) // Correctly use isHost to conditionally display the button
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: WideButton(
                text: 'Start Game',
                color: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage()),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: WideButton(
              text: 'Leave Game',
              color: Colors.red,
              onPressed: () async {
                // to-do : Still need to find a way to get roomCode and playerId
                String roomCode = "K22W824WUH"; // sample code
                String playerId = "RW1KW7PQ4R"; // sample code

                await DatabaseManager.removePlayerFromRoom(roomCode, playerId);

                //to-do : if ishost=true, then remove the entire room. And maybe kick out all players(?). 

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
