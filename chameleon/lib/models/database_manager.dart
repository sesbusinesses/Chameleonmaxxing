import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
      'players': [
        {
          'isCham': false,
          'playerID': creatorId,
          'username': username,
          'votingCham': "",
          'votingTopic': "",
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
          return players.map<String>((player) => player['username'] as String).toList();
        }
        return [];
      },
    );
  }

  static Stream<List<bool>> streamVotingStatus(String roomCode) {
    return _db.collection('room_code').doc(roomCode).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          List<dynamic> players = snapshot['players'];
          return players.map<bool>((player) => (player['votingTopic'] != null && player['votingTopic'] != "")).toList();
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

  static Stream<bool> streamDoesRoomExist(String roomCode) {
  return FirebaseFirestore.instance
      .collection('room_code')
      .doc(roomCode)
      .snapshots()
      .map((snapshot) => snapshot.exists);
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
    } catch (error) {
      print('Error getting votingCham status: $error');
    }
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
    } catch (error) {
      print('Error getting votingTopic status: $error');
    }
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
      print("Error fetching topics: $e");
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
        });
      }
    } catch (e) {
      print("Error starting game: $e");
    }
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
    } catch (e) {
      print("Error fetching initial selection: $e");
    }
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
    } catch (e) {
      print("Error updating player selection: $e");
    }
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
      print("Error fetching word list for topic $topic: $e");
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
    } catch (e) {
      print("Error fetching room topic for roomCode $roomCode: $e");
    }
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
          print("No topicWord found or topicWord is not a string.");
          return null;
        }
      } else {
        // Handle case where room document does not exist
        print("Room with code $roomCode does not exist.");
        return null;
      }
    } catch (e) {
      // Handle errors such as permission issues, network errors, etc.
      print("Error fetching topicWord for room $roomCode: $e");
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
    } catch (e) {
      print("Error checking if player is the chameleon: $e");
    }
    return false; // Return false if player not found or in case of any error
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

  // Method to count number of players in the game room with votingCham not null
  static Future<int> countPlayersVotingChamNotNull(String roomCode) async {
    DocumentSnapshot roomSnapshot = await _db.collection('room_code').doc(roomCode).get();
    if (roomSnapshot.exists) {
      List<dynamic> players = roomSnapshot.get('players');
      int count = players.where((player) => player['votingCham'] != null).length;
      return count;
    }
    return 0;
  }

}
