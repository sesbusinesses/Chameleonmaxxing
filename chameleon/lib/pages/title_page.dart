// ignore_for_file: unused_import

import 'package:chameleon/pages/waiting_people_page.dart';
import 'package:chameleon/pages/topic_page.dart';
import '../widgets/database_manager.dart';
import 'package:flutter/material.dart';
import '../widgets/wide_button.dart';
import 'join_page.dart';
import 'waiting_page.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  void doNothing() {
    // Function body can be expanded as needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Welcome to Chameleon!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.smart_toy,
              size: 100,
              color: Colors.green,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                WideButton(
                text: 'Create Game',
                onPressed: () async {
                  String roomCode = DatabaseManager.generateCode();
                  await DatabaseManager.storeRoomCode(roomCode);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WaitingPage(isHost: true,)),
                  );
                }, // Corrected: Pass function reference
              ),
            const SizedBox(height: 15),
            WideButton(
              text: 'Join Game',
              onPressed: () async{
                  String playerID = DatabaseManager.generateCode();
                  await DatabaseManager.storePlayerID(playerID);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JoinPage()),
                  );
                }, // Corre
            ),
            const SizedBox(height: 15),
            WideButton(
              text: 'Topics',
              onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TopicPage()),
                  );
                },
            ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
