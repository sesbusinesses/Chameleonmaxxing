import 'package:flutter/material.dart';
import 'game_topic_page.dart';
import 'game_people_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Page'),
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: const <Widget>[
          GameTopicPage(),
          GamePeoplePage(),
        ],
      ),
    );
  }
}
