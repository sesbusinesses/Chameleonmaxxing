import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/display_grid.dart';
import '../widgets/reveal_button.dart';
import '../helpers/list_fetcher.dart';
import 'dart:math';

class GameTopicPage extends StatefulWidget {
  GameTopicPage({Key? key}) : super(key: key);

  @override
  _GameTopicPageState createState() => _GameTopicPageState();
}

class _GameTopicPageState extends State<GameTopicPage> {
  Future<String> fetchFirstRoomVotedTopic() async {
    // Attempt to fetch the first room in the collection
    final querySnapshot = await FirebaseFirestore.instance
        .collection('room_code')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No rooms found");
    }

    // Assuming we're interested in the first room document
    final roomDoc = querySnapshot.docs.first;
    Map<String, int> voteCounts = {};
    
    // Assuming 'players' is a field within the room document
    List<dynamic> players = roomDoc.get('players') ?? [];
    for (var player in players) {
      String topic = player['votingTopic'];
      voteCounts[topic] = (voteCounts[topic] ?? 0) + 1;
    }

    // Determine the topic with the most votes
    var maxVotes = 0;
    List<String> winningTopics = [];
    voteCounts.forEach((topic, votes) {
      if (votes > maxVotes) {
        winningTopics = [topic];
        maxVotes = votes;
      } else if (votes == maxVotes) {
        winningTopics.add(topic);
      }
    });

    // Randomly select from the winning topics if there's a tie
    return winningTopics[Random().nextInt(winningTopics.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: FutureBuilder<String>(
              future: fetchFirstRoomVotedTopic(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    // Now fetch the words for the voted topic
                    return FutureBuilder<List<String>>(
                      future: fetchWordListForTopic(snapshot.data!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return DisplayGrid(
                              userList: snapshot.data!,
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error fetching words: ${snapshot.error}');
                          }
                        }
                        return CircularProgressIndicator();
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error determining winning topic: ${snapshot.error}');
                  }
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: RevealButton(
              text: 'Hold To Reveal Word',
              revealText: 'You Are Chameleon',
            ),
          ),
        ],
      ),
    );
  }
}

