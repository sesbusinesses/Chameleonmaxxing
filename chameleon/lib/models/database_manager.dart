import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  static String generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Corrected method to create a room and add the creator to it
  static Future<String> createRoomWithCreator(String creatorId) async {
    String roomCode = generateCode();
    await FirebaseFirestore.instance.collection('room_code').add({
      'code': roomCode,
      'players': [creatorId], // Add the creator's ID to the players array upon room creation
    });
    return roomCode; // Correctly return the room code for further use
  }

  static Future<void> storePlayerID(String code) async {
    await FirebaseFirestore.instance.collection('PlayID').add({'code': code});
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

  static Future<void> removePlayerFromRoom(String roomCode, String playerId) async {
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
            'players': FieldValue.arrayRemove([playerId]) // Remove the player ID from the players array
          });
    } 
  }

}
