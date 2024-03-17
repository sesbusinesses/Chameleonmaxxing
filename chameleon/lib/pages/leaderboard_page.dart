import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../models/player_score.dart'; // Make sure the path is correct

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
    // Fetch leaderboard scores using roomCode
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                PlayerScore score = snapshot.data![index];
                return ListTile(
                  leading: Text('#${index + 1}'),
                  title: Text(score.playerName),
                  trailing: Text('${score.score} pts'),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
