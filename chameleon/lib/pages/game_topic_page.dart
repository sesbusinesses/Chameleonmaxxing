import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/display_grid.dart';
import '../widgets/reveal_button.dart';

class GameTopicPage extends StatefulWidget {
  final String roomCode;
  final String playerId; // Ensure playerId is passed to GameTopicPage

  const GameTopicPage(
      {super.key, required this.roomCode, required this.playerId});

  @override
  _GameTopicPageState createState() => _GameTopicPageState();
}

class _GameTopicPageState extends State<GameTopicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: DatabaseManager.fetchRoomTopic(widget.roomCode),
        builder: (context, topicSnapshot) {
          if (topicSnapshot.connectionState == ConnectionState.done) {
            if (topicSnapshot.hasError ||
                !topicSnapshot.hasData ||
                topicSnapshot.data!.isEmpty) {
              return const Text('Error fetching topic or no topic found.');
            }
            String topic = topicSnapshot.data!;
            return FutureBuilder<List<String>>(
              future: DatabaseManager.fetchWordListForTopic(topic),
              builder: (context, wordsSnapshot) {
                if (wordsSnapshot.connectionState == ConnectionState.done) {
                  if (wordsSnapshot.hasError || !wordsSnapshot.hasData) {
                    return const Text('Error fetching words.');
                  }
                  List<String> words = wordsSnapshot.data!;
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Word List',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: DisplayGrid(userList: words)),
                      FutureBuilder<bool>(
                        future: DatabaseManager.isPlayerTheChameleon(
                            widget.roomCode, widget.playerId),
                        builder: (context, isChameleonSnapshot) {
                          if (isChameleonSnapshot.connectionState ==
                              ConnectionState.done) {
                            String revealText;
                            if (isChameleonSnapshot.hasData &&
                                isChameleonSnapshot.data!) {
                              revealText = 'You are the Chameleon!';
                            } else {
                              // Fetch the topic word if the player is not the chameleon
                              return FutureBuilder<String?>(
                                future: DatabaseManager.getTopicWord(
                                    widget.roomCode),
                                builder: (context, topicWordSnapshot) {
                                  if (topicWordSnapshot.connectionState ==
                                      ConnectionState.done) {
                                    revealText = topicWordSnapshot.data ??
                                        'Word not found';
                                  } else {
                                    revealText =
                                        'Loading...'; // Or some placeholder text
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: RevealButton(
                                        text: 'Press To Reveal Word',
                                        revealText: revealText),
                                  );
                                },
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RevealButton(
                                  text: 'Press To Reveal Word',
                                  revealText: revealText),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
