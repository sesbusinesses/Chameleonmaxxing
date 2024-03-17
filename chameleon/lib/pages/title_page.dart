import 'package:chameleon/pages/topic_page.dart';
import '../models/database_manager.dart';
import 'package:flutter/material.dart';
import '../widgets/wide_button.dart';
import 'join_page.dart';
import 'waiting_page.dart';
import 'profile_page.dart';


class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
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
                    String creatorID =
                        await DatabaseManager.generateCode(); // Generate a creator ID
                    String username = await DatabaseManager.loadUsername();
                    String roomCode =
                        await DatabaseManager.createRoomWithCreator(creatorID,
                            username); // Create room and add creator
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WaitingPage(
                              isHost: true,
                              roomCode: roomCode,
                              playerId: creatorID)),
                    );
                  },
                ),
                const SizedBox(height: 15),
                WideButton(
                  text: 'Join Game',
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JoinPage()),
                    );
                  },
                ),
                const SizedBox(height: 15),
                WideButton(
                  text: 'Topics',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TopicPage()),
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
