import 'package:flutter/material.dart';
import '../widgets/display_grid.dart';
import '../widgets/reveal_button.dart';

class GameTopicPage extends StatelessWidget {
  const GameTopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            // Wrap DisplayGrid with Expanded
            child: DisplayGrid(
              userList: const [
                'TopicWord1',
                'TopicWord2',
                'TopicWord3',
                'TopicWord4'
              ], // Example topics
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: RevealButton(
              text: 'Hold To Reveal Word',
              revealText: 'You Are Chameleon',
            ),
          ),
        ],
      ),
    );
  }
}
