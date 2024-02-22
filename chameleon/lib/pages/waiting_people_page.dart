import 'package:flutter/material.dart';
import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';

class WaitingPeoplePage extends StatelessWidget {
  const WaitingPeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const DisplayGrid(
            displayList: ['Player1', 'Player2', 'Player3', 'Player4'], // Example usernames
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: WideButton(
              text: 'Cancel',
              color: Colors.red,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
