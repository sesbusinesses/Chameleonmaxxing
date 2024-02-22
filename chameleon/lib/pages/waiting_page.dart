import 'package:flutter/material.dart';

import 'waiting_people_page.dart';
import 'waiting_topics_page.dart';

class WaitingPage extends StatelessWidget {
  const WaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold to provide appBar and structure
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Code: ABCXYZ'),
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      // PageView for horizontal swiping
      body: PageView(
        scrollDirection: Axis.horizontal, // Specifies the swiping direction
        children: const <Widget>[
          WaitingPeoplePage(), // First instance of the WaitingPage
          WaitingTopicsPage(), // Second instance, can customize differently if needed
        ],
      ),
    );
  }
}
