import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  static String generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Corrected method to create a room and add the creator to it
  static Future<String> createRoomWithCreator(String creatorId) async {
    String roomCode = generateCode();
    await FirebaseFirestore.instance.collection('room_code').add({
      'code': roomCode,
      'players': [
        creatorId
      ], // Add the creator's ID to the players array upon room creation
    });
    return roomCode; // Correctly return the room code for further use
  }

  static Future<void> addPlayerToRoom(String roomCode, String playerId) async {
    var roomQuery = await FirebaseFirestore.instance
    .collection('room_code')
    .where('code', isEqualTo: roomCode)
    .limit(1)
    .get();

    if (roomQuery.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('room_code')
          .doc(roomQuery.docs.first.id)
          .update({
        'players': FieldValue.arrayUnion([playerId])
      });
    }
  }

  static Future<bool> doesRoomExist(String roomCode) async {
    var roomQuery = await FirebaseFirestore.instance
        .collection('room_code')
        .where('code', isEqualTo: roomCode)
        .limit(1)
        .get();

    return roomQuery.docs.isNotEmpty;
  }

  // Remove a player ID from the room
  static Future<void> removePlayerFromRoom(
      String roomCode, String playerId) async {
    var roomQuery = await FirebaseFirestore.instance
        .collection('room_code')
        .where('code', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomQuery.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('room_code')
          .doc(roomQuery.docs.first.id)
          .update({
        'players': FieldValue.arrayRemove(
            [playerId]) // Remove the player ID from the players array
      });
    }
  }

  // this method removes the entire room if the user is the host
  static Future<void> removeEntireRoom(String roomCode) async {
    var roomQuery = await FirebaseFirestore.instance
        .collection('room_code')
        .where('code', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomQuery.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('room_code')
          .doc(roomQuery.docs.first.id)
          .delete();
    }
  }

  // Fetch the list of player IDs from a room
  static Future<List<String>> getPlayersInRoom(String roomCode) async {
    var roomQuery = await FirebaseFirestore.instance
        .collection('room_code')
        .where('code', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (roomQuery.docs.isNotEmpty) {
      // Assuming 'players' is stored as an array of strings (player IDs)
      List<String> playerIds = List.from(roomQuery.docs.first.get('players'));
      return playerIds;
    } else {
      return []; // Return an empty list if the room doesn't exist
    }
  }
}
