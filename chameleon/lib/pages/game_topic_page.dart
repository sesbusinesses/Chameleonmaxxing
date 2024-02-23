import 'package:flutter/material.dart';
import '../widgets/display_grid.dart';
import '../widgets/reveal_button.dart';
// Assuming DisplayGrid can be used or adapted for topics

class GameTopicPage extends StatelessWidget {
  const GameTopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          DisplayGrid(
            userList: const ['TopicWord1', 'TopicWord2', 'TopicWord3', 'TopicWord4'], // Example topics
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: RevealButton(
              text: 'Reveal Word',
              revealText: 'You Are Chameleon',
            )
          )
        ]
      )
    );
  }
}
