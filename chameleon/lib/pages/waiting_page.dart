import 'package:flutter/material.dart';

import 'waiting_people_page.dart';
import 'waiting_topics_page.dart';

class WaitingPage extends StatelessWidget {
  final bool isHost; // Allow external initialization

  // Modified constructor to accept isHost value
  const WaitingPage({super.key, this.isHost = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Code: ABCXYZ'),
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          WaitingPeoplePage(isHost: isHost), // Pass isHost to WaitingPeoplePage
          const WaitingTopicsPage(), // No changes needed here
        ],
      ),
    );
  }
}
