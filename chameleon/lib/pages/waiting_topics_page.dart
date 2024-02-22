import 'package:flutter/material.dart';
import '../widgets/selectable_grid.dart';

class WaitingTopicsPage extends StatelessWidget {
  const WaitingTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Choose a Topic',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SelectableGrid(
            displayList: ['topic1', 'topic2', 'topic3', 'topic4'], // Example usernames
            color: Colors.grey,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
