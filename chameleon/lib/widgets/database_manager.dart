import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  // Function to generate a random room code
  static String generateCode() {
    const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(10, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  // Function to store the room code in Firestore
  static Future<void> storeRoomCode(String code) async {
    await FirebaseFirestore.instance.collection('room_code').add({'code': code});
  }

  static Future<void> storePlayerID(String code) async {
    await FirebaseFirestore.instance.collection('PlayID').add({'code': code});
  }
}
