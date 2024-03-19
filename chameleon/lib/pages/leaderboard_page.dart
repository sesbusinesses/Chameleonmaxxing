import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../models/player_score.dart'; // Ensure this path matches your project structure

class LeaderboardPage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const LeaderboardPage({
    Key? key,
    required this.roomCode,
    required this.playerId,
  }) : super(key: key);

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
      body: FutureBuilder<List<PlayerScore>>(
        future: leaderboardScores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                PlayerScore score = snapshot.data![index];
                return ListTile(
                  leading:
                      Text('#${index + 1}', style: TextStyle(fontSize: 16)),
                  title: Text(score.playerName, style: TextStyle(fontSize: 16)),
                  trailing: Text('${score.score} pts',
                      style: TextStyle(fontSize: 16)),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
