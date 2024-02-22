import 'package:flutter/material.dart';

import '../widgets/selectable_grid.dart';
// Import your SelectableGrid widget here

class GamePeoplePage extends StatelessWidget {
  const GamePeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: SelectableGrid(
        displayList: ['Player 1', 'Player 2', 'Player 3', 'Player 4'], // Example players
        // Additional properties for SelectableGrid if needed
      ),
      )
    );
  }
}
