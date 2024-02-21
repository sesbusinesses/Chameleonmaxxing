import 'package:flutter/material.dart';

import '../widgets/display_grid.dart';
import '../widgets/wide_button.dart';

class WaitingPage extends StatelessWidget {
  const WaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Waiting Page',
        ),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Join Code: ABCXYZ',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
              DisplayGrid(
                usernames: ['Player1', 'Player2', 'Player3', 'Player4'], // Example usernames
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: WideButton(
              text: 'Cancel',
              color: Colors.red,
              onPressed: (){
                Navigator.pop(context);
              }, // Corrected: Pass function reference
        ),
      )
    );
  }
}
