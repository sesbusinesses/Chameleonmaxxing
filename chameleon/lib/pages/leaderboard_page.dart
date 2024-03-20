import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../models/player_score.dart'; // Make sure this path matches your project structure

class LeaderboardPage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const LeaderboardPage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<PlayerScore>> leaderboardScores;

  @override
  void initState() {
    super.initState();
    leaderboardScores = DatabaseManager.getLeaderboardScores(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<PlayerScore>>(
          future: leaderboardScores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        (Scaffold.of(context).appBarMaxHeight ?? 0),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...snapshot.data!.asMap().entries.map<Widget>((entry) {
                          int index = entry.key;
                          PlayerScore score = entry.value;
                          Color? backgroundColor;
                          if (index == 0) {
                            backgroundColor = Color(0xFFffb703);
                          } else if (index == 1) {
                            backgroundColor = Color(0xFFccc5b9);
                          } else if (index == 2) {
                            backgroundColor = Color(0xFFd4a373);
                          }
                          List<Widget> widgets = [
                            Container(
                              color: backgroundColor,
                              child: ListTile(
                                leading: Text('#${index + 1}',
                                    style: const TextStyle(fontSize: 16)),
                                title: Text(score.playerName,
                                    style: const TextStyle(fontSize: 16)),
                                trailing: Text('${score.score} pts',
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ];
                          // Check if this is not the last entry, then add a Divider
                          if (index != snapshot.data!.length - 1) {
                            widgets.add(const Divider());
                          }
                          return Column(children: widgets);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
