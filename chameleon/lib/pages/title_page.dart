// ignore_for_file: use_build_context_synchronously

import 'package:chameleon/pages/topic_page.dart';
import '../models/database_manager.dart';
import 'package:flutter/material.dart';
import '../widgets/utility.dart';
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 40,
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
              'Aliens From SES',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(
              'assets/images/alien2.webp',
              width: 300, // Set the width as needed
              height: 300, // Set the height as needed
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                WideButton(
                  text: 'Create Game',
                  onPressed: () async {
                    String creatorID =
                        DatabaseManager.generateCode(); // Generate a creator ID
                    String username = await DatabaseManager.loadUsername();
                    if (username.isEmpty) {
                      showMessage(context, 'Please enter a username');
                    } else {
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
                    }
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
