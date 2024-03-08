import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
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

  static Future<void> startGame(String roomCode) async {
    try {
      DocumentReference roomRef = _db.collection('room_code').doc(roomCode);

      // Fetch the room document to get the list of players
      DocumentSnapshot roomDoc = await roomRef.get();
      if (roomDoc.exists && roomDoc.data() != null) {
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        List<dynamic> players = roomData['players'];
        if (players.isNotEmpty) {
          // Select a random player to be the chameleon
          Random rnd = Random();
          int randomIndex = rnd.nextInt(players.length);
          for (int i = 0; i < players.length; i++) {
            // Reset isCham to false for all players, then set true for the selected player
            Map<String, dynamic> player = players[i];
            player['isCham'] = i == randomIndex;
            players[i] = player;
          }

          // Update the room document: start the game and update players with the selected chameleon
          await roomRef.update({
            'gameRunning': true,
            'players': players,
          });
        }
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
}
