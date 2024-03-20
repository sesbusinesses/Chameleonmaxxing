import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/selectable_grid.dart';

class ChamGuessPage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const ChamGuessPage(
      {super.key, required this.roomCode, required this.playerId});

  @override
  ChamGuessPageState createState() => ChamGuessPageState();
}

class ChamGuessPageState extends State<ChamGuessPage> {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Guess the Word',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SelectableGrid(
                            displayList: words,
                            color: Colors.grey,
                            updateField:
                                'chamGuess', // Assuming you handle the guess in your database logic
                            roomCode: widget.roomCode,
                            playerId: widget.playerId),
                      ),
                      const SizedBox(
                        height: 10,
                      )
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
