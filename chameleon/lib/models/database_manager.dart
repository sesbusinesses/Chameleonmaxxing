// ignore_for_file: empty_catches

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_score.dart';

class DatabaseManager {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> resetToPlayAgain(String roomCode) async {
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .get();

    // Check if the room exists and has data
    if (!roomSnapshot.exists || roomSnapshot.data() == null) {
      return; // Exit the function if room does not exist
    }

    // Proceed to reset the room if it exists
    await FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .update({
      'voteNum': FieldValue.delete(), // Remove the voteNum field
      'topicWord': FieldValue.delete(), // Remove the topicWord field
      'Topic': FieldValue.delete(), // Remove the Topic field
      'gameRunning': false, // Set gameRunning to false
      'firstGame': false, // Set firstGame to false
      // Add more fields to reset if necessary
    });

    List<dynamic> players = roomSnapshot.get('players');
    List<dynamic> updatedPlayers = players.map((player) {
      // Initialize an updatedPlayer variable to hold changes
      Map updatedPlayer = Map.from(player);

      // Check if the player is the champion and needs chamGuess to be removed
      if (updatedPlayer['isCham'] == true) {
        updatedPlayer.remove('chamGuess'); // Remove 'chamGuess' field
      }

      // Reset fields for every player
      updatedPlayer['playAgain'] = false;
      updatedPlayer['isCham'] = false;
      updatedPlayer['votingCham'] = "";
      updatedPlayer['votingTopic'] = "";
      // Add other fields to reset if necessary

      return updatedPlayer; // Return the updated player information
    }).toList();

    // Update the room document with the reset players' information
    await FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .update({'players': updatedPlayers});
  }

  static String generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  static Future<String> createRoomWithCreator(
      String creatorId, String username) async {
    String roomCode = generateCode();
    await _db.collection('room_code').doc(roomCode).set({
      'code': roomCode,
      'gameRunning': false,
      'firstGame': true,
      'players': [
        {
          'isCham': false,
          'playerID': creatorId,
          'username': username,
          'votingCham': "",
          'votingTopic': "",
          'score': 0, // Initialize the score to 0 for the creator
          'playAgain': false,
          'isHost': true,
        }
      ]
    });
    return roomCode;
  }

  static Future<void> addPlayerToRoom(
      String roomCode, String playerId, String username) async {
    Map<String, dynamic> playerDetail = {
      'isCham': false,
      'playerID': playerId,
      'username': username,
      'votingCham': "",
      'votingTopic': "",
      'score': 0, // Assign a starting score of zero for the new player
      'playAgain': false,
      'isHost': false,
    };

    DocumentReference roomRef = _db.collection('room_code').doc(roomCode);
    await roomRef.update({
      'players': FieldValue.arrayUnion([playerDetail])
    });
  }

  static Future<bool> doesRoomExist(String roomCode) async {
    DocumentSnapshot roomDoc =
        await _db.collection('room_code').doc(roomCode).get();
    return roomDoc.exists;
  }

  static Future<void> removePlayerFromRoom(
      String roomCode, String playerId) async {
    DocumentReference roomRef = _db.collection('room_code').doc(roomCode);
    DocumentSnapshot roomSnapshot = await roomRef.get();
    if (roomSnapshot.exists) {
      List<dynamic> players = roomSnapshot['players'];
      List<dynamic> updatedPlayers =
          players.where((player) => player['playerID'] != playerId).toList();
      await roomRef.update({'players': updatedPlayers});
    }
  }

  static Future<void> removeEntireRoom(String roomCode) async {
    await _db.collection('room_code').doc(roomCode).delete();
  }

  static Future<List<String>> getPlayerUsernames(String roomCode) async {
    DocumentSnapshot roomSnapshot =
        await _db.collection('room_code').doc(roomCode).get();
    if (roomSnapshot.exists) {
      List<dynamic> players = roomSnapshot['players'];
      return players
          .map<String>((player) => player['username'] as String)
          .toList();
    }
    return [];
  }

  static Stream<List<String>> streamPlayerUsernames(String roomCode) {
    return _db.collection('room_code').doc(roomCode).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          List<dynamic> players = snapshot['players'];
          return players
              .map<String>((player) => player['username'] as String)
              .toList();
        }
        return [];
      },
    );
  }

  static Stream<int> streamVoteNum(String roomCode) {
    return _db.collection('room_code').doc(roomCode).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          List<dynamic> players = snapshot['players'];
          int voteCount = players
              .where((player) =>
                  player['votingCham'] != null &&
                  player['votingCham'].toString().isNotEmpty)
              .length;
          return voteCount;
        }
        return 0;
      },
    );
  }

  static Stream<List<bool>> streamVotingStatus(String roomCode) {
    return _db.collection('room_code').doc(roomCode).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          List<dynamic> players = snapshot['players'];
          return players
              .map<bool>((player) => (player['votingTopic'] != null &&
                  player['votingTopic'] != ""))
              .toList();
        }
        return [];
      },
    );
  }

  static Stream<List<bool>> streamPlayAgainStatus(String roomCode) {
    return _db.collection('room_code').doc(roomCode).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          List<dynamic> players = snapshot['players'];
          return players
              .map<bool>((player) =>
                  (player['playAgain'] != null && player['playAgain'] == true))
              .toList();
        }
        return [];
      },
    );
  }

  static Stream<bool> streamGameRunning(String roomCode) {
    return _db.collection('room_code').doc(roomCode).snapshots().map(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          Map<String, dynamic> data = snapshot.data()!;
          return data['gameRunning'] ?? false;
        }
        return false;
      },
    );
  }

  static Future<void> setPlayerVotingCham(
      String roomCode, String playerId, String votingCham) async {
    var roomQuery = await FirebaseFirestore.instance
        .collection('room_code')
        .where('code', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomQuery.docs.isNotEmpty) {
      // Assuming 'players' is an array of maps
      var docId = roomQuery.docs.first.id;
      var players = List.from(roomQuery.docs.first.get('players'));
      var updatedPlayers = players.map((player) {
        if (player is Map && player['playerID'] == playerId) {
          return {...player, 'votingCham': votingCham};
        }
        return player;
      }).toList();

      await FirebaseFirestore.instance
          .collection('room_code')
          .doc(docId)
          .update({'players': updatedPlayers});
    }
  }

  static Future<void> setPlayerVotingTopic(
      String roomCode, String playerId, String votingTopic) async {
    var roomQuery = await FirebaseFirestore.instance
        .collection('room_code')
        .where('code', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomQuery.docs.isNotEmpty) {
      // Assuming 'players' is an array of maps
      var docId = roomQuery.docs.first.id;
      var players = List.from(roomQuery.docs.first.get('players'));
      var updatedPlayers = players.map((player) {
        if (player is Map && player['playerID'] == playerId) {
          return {...player, 'votingTopic': votingTopic};
        }
        return player;
      }).toList();

      await FirebaseFirestore.instance
          .collection('room_code')
          .doc(docId)
          .update({'players': updatedPlayers});
    }
  }

  static Future<List<bool>> getVotingChamStatus(String roomCode) async {
    try {
      DocumentSnapshot roomSnapshot =
          await _db.collection('room_code').doc(roomCode).get();
      if (roomSnapshot.exists && roomSnapshot.data() != null) {
        List<dynamic> players = roomSnapshot.get('players');
        return players
            .map<bool>((player) =>
                player['votingCham'] != null && player['votingCham'] != "")
            .toList();
      }
    } catch (error) {}
    return [];
  }

  static Future<List<bool>> getVotingTopicStatus(String roomCode) async {
    try {
      DocumentSnapshot roomSnapshot =
          await _db.collection('room_code').doc(roomCode).get();
      if (roomSnapshot.exists && roomSnapshot.data() != null) {
        List<dynamic> players = roomSnapshot.get('players');
        return players
            .map<bool>((player) =>
                player['votingTopic'] != null && player['votingTopic'] != "")
            .toList();
      }
    } catch (error) {}
    return [];
  }

// Fetches all topics from the 'card_topics' collection
  static Future<List<String>> fetchTopics() async {
    try {
      final querySnapshot = await _db.collection('card_topics').get();
      List<String> topics = querySnapshot.docs
          .map((doc) => doc.id)
          .toList(); // Assuming the document ID is the topic name
      return topics;
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Function to start the game by selecting a chameleon and setting a random topic
  static Future<void> startGame(String roomCode) async {
    try {
      DocumentReference roomRef = _db.collection('room_code').doc(roomCode);
      DocumentSnapshot roomDoc = await roomRef.get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Select a random player to be the chameleon
        Random rnd = Random();
        int randomIndex = rnd.nextInt(players.length);
        Map<String, int> topicVotes = {};

        for (int i = 0; i < players.length; i++) {
          Map<String, dynamic> player = players[i];
          player['isCham'] = i == randomIndex;
          players[i] = player;

          String votingTopic = player['votingTopic'] ?? '';
          if (votingTopic.isNotEmpty) {
            topicVotes[votingTopic] = (topicVotes[votingTopic] ?? 0) + 1;
          }
        }

        for (int i = 0; i < players.length; i++) {
          players[i]['playAgain'] =
              false; // Reset 'playAgain' to false for all players
        }

        // Determine the topic for the game
        String mostCommonTopic = '';
        List<String> wordList = [];
        if (topicVotes.isNotEmpty) {
          mostCommonTopic = topicVotes.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
          wordList = await fetchWordListForTopic(mostCommonTopic);
        } else {
          // If no topic has been voted on, select one at random from the topics collection
          List<String> topics = await fetchTopics();
          mostCommonTopic = topics[rnd.nextInt(topics.length)];
          wordList = await fetchWordListForTopic(mostCommonTopic);
        }

        // Select a random word from the chosen topic's word list
        String topicWord =
            wordList.isNotEmpty ? wordList[rnd.nextInt(wordList.length)] : "";

        // Update the room document: start the game, update players with the selected chameleon, set the Topic, and topicWord
        await roomRef.update({
          'gameRunning': true,
          'players': players,
          'Topic': mostCommonTopic,
          'topicWord': topicWord,
          'voteNum': 0,
        });
      }
    } catch (e) {}
  }

  // Fetches the initial selection based on the updateField for a given player
  static Future<String?> fetchInitialSelection(
      String roomCode, String playerId, String updateField) async {
    try {
      DocumentSnapshot roomSnapshot =
          await _db.collection('room_code').doc(roomCode).get();
      if (roomSnapshot.exists) {
        List<dynamic> players = roomSnapshot['players'];
        var currentPlayer = players.firstWhere(
            (player) => player['playerID'] == playerId,
            orElse: () => null);
        if (currentPlayer != null) {
          return currentPlayer[
              updateField]; // This will be either a String or null
        }
      }
    } catch (e) {}
    return null;
  }

  // Updates the player's selection in Firestore based on the updateField
  static Future<void> updatePlayerSelection(String roomCode, String playerId,
      String updateField, String selection) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('room_code').doc(roomCode).get();
      if (doc.exists) {
        List<dynamic> players = doc['players'];
        List<dynamic> updatedPlayers = players.map((player) {
          if (player['playerID'] == playerId) {
            player[updateField] = selection;
          }
          return player;
        }).toList();
        await _db
            .collection('room_code')
            .doc(roomCode)
            .update({'players': updatedPlayers});
      }
    } catch (e) {}
  }

  // Fetches a word list for a specific topic from the 'card_topics' collection
  static Future<List<String>> fetchWordListForTopic(String topic) async {
    try {
      final docRef = _db.collection('card_topics').doc(topic);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data()!.containsKey('wordList')) {
        List<String> wordList = List<String>.from(snapshot.data()!['wordList']);
        return wordList;
      } else {
        return []; // Return empty list if 'wordList' key doesn't exist or document doesn't exist
      }
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Fetches the current topic for a room given its room code
  static Future<String?> fetchRoomTopic(String roomCode) async {
    try {
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

        // Check if the 'currentTopic' field exists and is a String
        if (roomData.containsKey('Topic') && roomData['Topic'] is String) {
          return roomData['Topic'];
        }
      }
    } catch (e) {}
    return null; // Return null if there's no topic or in case of an error
  }

  // Function to fetch the topicWord for a given room
  static Future<String?> getTopicWord(String roomCode) async {
    try {
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

        // Check if 'topicWord' exists in the room document and return it
        if (roomData.containsKey('topicWord') &&
            roomData['topicWord'] is String) {
          return roomData['topicWord'];
        } else {
          // Handle case where 'topicWord' does not exist or is not a string
          return null;
        }
      } else {
        // Handle case where room document does not exist
        return null;
      }
    } catch (e) {
      // Handle errors such as permission issues, network errors, etc.
      return null;
    }
  }

  // Method to check if a specific player is the chameleon
  static Future<bool> isPlayerTheChameleon(
      String roomCode, String playerId) async {
    try {
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        for (var player in players) {
          if (player['playerID'] == playerId) {
            // Check if the player is marked as the chameleon
            return player['isCham'] ?? false;
          }
        }
      }
    } catch (e) {}
    return false; // Return false if player not found or in case of any error
  }

  static Stream<bool> streamDoesRoomExist(String roomCode) {
    return FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Method to count number of players in the game room
  static Future<int> countPlayersInRoom(String roomCode) async {
    DocumentSnapshot roomSnapshot =
        await _db.collection('room_code').doc(roomCode).get();
    if (roomSnapshot.exists) {
      List<dynamic> players = roomSnapshot['players'];
      return players.length;
    }
    return 0;
  }

  static Stream<bool> getVoteNumStream(String roomCode) {
    StreamController<bool> controller = StreamController<bool>();

    // This variable will hold the latest player count.
    int? latestPlayerCount;

    // Start listening to the player count updates.
    // You may want to handle this more robustly in a real app, e.g., refreshing periodically.
    countPlayersInRoom(roomCode).then((count1) {
      latestPlayerCount = count1;
    }).catchError((_) {
      latestPlayerCount = 0; // Handle error or maintain old count
    });

    // Subscribe to voteNum changes from Firestore.
    FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .snapshots()
        .listen((snapshot) {
      final voteNum = snapshot.data()?['voteNum'] as int? ?? 0;

      // Check if we have a latest player count and compare.
      if (latestPlayerCount != null) {
        controller.add(voteNum > latestPlayerCount!);
      }
    }).onError((_) {
      controller.add(false); // Handle stream errors or complete the stream
    });

    return controller.stream;
  }

  // Setter method for voteNum
  static Future<void> updateVoteNum(String roomCode) async {
    DocumentReference roomRef = _db.collection('room_code').doc(roomCode);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception("Room does not exist!");
      }

      int currentVoteNum = snapshot['voteNum'] ??
          0; // Get the current number of votes, defaulting to 0 if none
      transaction.update(roomRef,
          {'voteNum': currentVoteNum + 1}); // Increment the vote number by 1
    });
  }

  static Future<String?> getChameleonPlayerId(String roomCode) async {
    try {
      // Fetch the room document by roomCode
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      // Check if the document exists and has data
      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Find the player marked as the chameleon
        var chameleon = players.firstWhere(
          (player) => player['isCham'] == true,
          orElse: () => null,
        );

        // Return the chameleon's playerID if found
        return chameleon != null ? chameleon['playerID'] : null;
      }
    } catch (e) {}
    return null; // Return null if not found or on error
  }

  static Future<bool> wasChameleonCaught(String roomCode) async {
    try {
      // Fetch the room document by roomCode
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];
        String? chameleonUsername;

        // Identify the chameleon's playerID
        for (var player in players) {
          if (player['isCham'] == true) {
            chameleonUsername = player['username'];
            break;
          }
        }

        if (chameleonUsername == null) {
          return false; // No chameleon found, or error in data structure
        }

        // Count votes for each player
        Map<String, int> voteCounts = {};
        for (var player in players) {
          String votedFor = player['votingCham'] ?? '';
          if (votedFor.isNotEmpty) {
            voteCounts[votedFor] = (voteCounts[votedFor] ?? 0) + 1;
          }
        }

        // Determine if the chameleon was most voted for
        String? mostVotedFor = voteCounts.entries
            .reduce((curr, next) => curr.value > next.value ? curr : next)
            .key;
        return chameleonUsername == mostVotedFor;
      }
    } catch (e) {}
    return false; // Default return false if unable to determine or on error
  }

  static Future<String?> getChameleonUsername(String roomCode) async {
    try {
      // Fetch the room document by roomCode
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Iterate through players to find the chameleon
        for (var player in players) {
          if (player['isCham'] == true) {
            return player['username']; // Return the username of the chameleon
          }
        }
      }
    } catch (e) {}
    return null; // Return null if chameleon's username couldn't be found or on error
  }

  static Future<bool> isThereTie(String roomCode) async {
    try {
      // Fetch the room document by roomCode
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Count votes for each player
        Map<String, int> voteCounts = {};
        for (var player in players) {
          String votedFor = player['votingCham'] ?? '';
          if (votedFor.isNotEmpty) {
            voteCounts[votedFor] = (voteCounts[votedFor] ?? 0) + 1;
          }
        }

        // Find the highest vote count
        int highestVoteCount = 0;
        if (voteCounts.isNotEmpty) {
          highestVoteCount = voteCounts.values.reduce((a, b) => a > b ? a : b);
        }

        // Count how many players received the highest vote count
        int numPlayersWithHighestVotes =
            voteCounts.values.where((v) => v == highestVoteCount).length;

        // If there is more than one player with the highest votes, then it's a tie
        return numPlayersWithHighestVotes > 1;
      }
    } catch (e) {
      // Error handling can be more specific based on requirements
    }
    return false; // Return false if unable to determine or on error
  }

  static Future<void> resetVoteNum(String roomCode) async {
    try {
      DocumentReference roomRef = _db.collection('room_code').doc(roomCode);
      // Fetch the room document by roomCode to check if it exists
      DocumentSnapshot roomDoc = await roomRef.get();

      if (roomDoc.exists) {
        // Only update the voteNum to 0 if the room document exists
        await roomRef.update({'voteNum': 0});
      }
    } catch (e) {
      // Handle any errors that occur during the update
      // Or use a more sophisticated error handling approach
    }
  }

  static Future<void> resetToRevote(String roomCode) async {
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .get();

    // Check if the room exists and has data
    if (!roomSnapshot.exists || roomSnapshot.data() == null) {
      return; // Exit the function if the room does not exist
    }

    List<dynamic> players = roomSnapshot.get('players');
    List<dynamic> updatedPlayers = players.map((player) {
      Map<String, dynamic> updatedPlayer = Map<String, dynamic>.from(player);
      // Reset 'votingCham' for every player
      updatedPlayer['votingCham'] = "";
      // Check if the player is the champion and needs chamGuess to be removed
      if (updatedPlayer['isCham'] == true) {
        updatedPlayer.remove('chamGuess'); // Remove 'chamGuess' field
      }

      return updatedPlayer; // Return the updated player information
    }).toList();

    // Update the room with the reset players
    await FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .update({'players': updatedPlayers});
  }

  static Future<void> endGame(String roomCode) async {
    try {
      DocumentReference roomRef = _db.collection('room_code').doc(roomCode);
      DocumentSnapshot roomSnapshot = await roomRef.get();

      if (!roomSnapshot.exists || roomSnapshot.data() == null) {
        return;
      }

      List<dynamic> players = List.from(roomSnapshot['players']);
      String? topicWord = roomSnapshot['topicWord'];
      Map<String, dynamic> chameleon;
      List<Map<String, dynamic>> updatedPlayers = [];
      bool chameleonGuessedWord = false;

      // First, identify the chameleon
      chameleon = players.firstWhere((player) => player['isCham'] == true,
          orElse: () => null);

      chameleonGuessedWord = chameleon['chamGuess'] == topicWord;

      // Iterate over players to update scores
      for (var player in players) {
        Map<String, dynamic> updatedPlayer = Map<String, dynamic>.from(player);
        if (player['playerID'] != chameleon['playerID'] &&
            player['votingCham'] == chameleon['username']) {
          // Increment score for correct guesses
          updatedPlayer['score'] = (player['score'] ?? 0) + 1;
        }
        if (player['playerID'] == chameleon['playerID'] &&
            chameleonGuessedWord) {
          updatedPlayer['score'] = (player['score'] ?? 0) + 2;
        }
        updatedPlayers.add(updatedPlayer);
      }

      // Use a transaction to atomically update the players' scores and reset game state
      await _db.runTransaction((transaction) async {
        transaction.update(roomRef, {
          'players': updatedPlayers,
          'voteNum': 0, // Reset vote count or any other game state as needed
        });
      });
    } catch (e) {}
  }

  static Stream<bool> getPlayAgainNumStream(String roomCode) {
    StreamController<bool> controller = StreamController<bool>();

    // This variable will hold the latest player count.
    int? latestPlayerCount;

    // Start listening to the player count updates.
    // You may want to handle this more robustly in a real app, e.g., refreshing periodically.
    countPlayersInRoom(roomCode).then((count2) {
      latestPlayerCount = count2;
    }).catchError((_) {
      latestPlayerCount = 0; // Handle error or maintain old count
    });

    // Subscribe to voteNum changes from Firestore.
    FirebaseFirestore.instance
        .collection('room_code')
        .doc(roomCode)
        .snapshots()
        .listen((snapshot) {
      final voteNum = snapshot.data()?['voteNum'] as int? ?? 0;

      // Check if we have a latest player count and compare.
      if (latestPlayerCount != null) {
        controller.add(voteNum > latestPlayerCount! - 1);
      }
    }).onError((_) {
      controller.add(false); // Handle stream errors or complete the stream
    });

    return controller.stream;
  }

  static Future<bool> isHost(String roomCode, String playerId) async {
    try {
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Look for the player with the given playerId
        var player = players.firstWhere(
          (player) => player['playerID'] == playerId,
          orElse: () => null,
        );

        // Check if the player is marked as the host
        if (player != null) {
          return player['isHost'] ?? false;
        }
      }
    } catch (e) {}
    return false; // Return false if the player is not found, or in case of any error
  }

  static Future<int> getPlayerScore(String roomCode, String playerId) async {
    try {
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Look for the player with the given playerId
        var player = players.firstWhere(
          (player) => player['playerID'] == playerId,
          orElse: () => null,
        );

        // Return the player's score if found
        if (player != null) {
          return player['score'] ?? 0; // Default to 0 if 'score' is not set
        }
      }
    } catch (e) {}
    return 0; // Return 0 if the player is not found, or in case of any error
  }

  // Function to set 'playAgain' = true for a provided player
  static Future<void> votePlayAgain(String roomCode, String playerId) async {
    try {
      // Reference to the specific room
      DocumentReference roomRef = _db.collection('room_code').doc(roomCode);
      DocumentSnapshot roomSnapshot = await roomRef.get();

      if (roomSnapshot.exists && roomSnapshot.data() != null) {
        List<dynamic> players = List.from(roomSnapshot['players']);
        List<Map<String, dynamic>> updatedPlayers = [];

        // Iterate through all players to find the matching playerId
        for (var player in players) {
          Map<String, dynamic> updatedPlayer =
              Map<String, dynamic>.from(player);
          if (player['playerID'] == playerId) {
            // Set 'playAgain' to true for the matched player
            updatedPlayer['playAgain'] = true;
          }
          updatedPlayers.add(updatedPlayer);
        }

        // Update the room document with the modified players array
        await roomRef.update({'players': updatedPlayers});
      }
    } catch (e) {}
  }

  static Future<String> loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ??
        'Default Username'; // Use a default value or leave empty
  }

  static Future<List<PlayerScore>> getLeaderboardScores(String roomCode) async {
    try {
      // Fetch the room document by its roomCode
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];

        // Sort players by their score in descending order
        players.sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

        // Map each player to a PlayerScore object
        List<PlayerScore> scores = players.map<PlayerScore>((player) {
          return PlayerScore(
            playerName:
                player['username'], // Adjust field name as per your database
            score: player['score'], // Adjust field name as per your database
          );
        }).toList();

        return scores;
      }
    } catch (e) {
      return []; // Return an empty list in case of error
    }
    return []; // Return an empty list if the room document does not exist or has no data
  }

  static Future<bool> checkUsernameInRoom(
      String roomCode, String username) async {
    try {
      // Fetch the room document by roomCode
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();

      if (roomDoc.exists && roomDoc.data() != null) {
        // Extract players list from room document
        List<dynamic> players = roomDoc.get('players');

        // Check if any player in the list has the provided username
        for (var player in players) {
          if (player['username'] == username) {
            return true; // Username exists in the room
          }
        }
      }
    } catch (e) {}
    return false; // Username does not exist in the room or an error occurred
  }

  static Future<bool> isFirstGame(String roomCode) async {
    try {
      DocumentSnapshot roomDoc =
          await _db.collection('room_code').doc(roomCode).get();
      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        // Check if 'firstGame' field exists and return its value, otherwise return false
        return roomData['firstGame'] ?? false;
      }
    } catch (e) {}
    // If the document does not exist, or 'firstGame' field is not present, return false
    return false;
  }
}
