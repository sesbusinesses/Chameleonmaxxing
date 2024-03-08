import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> fetchTopics() async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('card_topics').get();

  List<String> topics = [];
  for (var doc in querySnapshot.docs) {
    topics.add(doc.id); // Assuming the document ID is the topic name
  }
  return topics;
}

Future<List<String>> fetchWordListForTopic(String topic) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('card_topics').doc(topic);
  final snapshot = await docRef.get();

  if (snapshot.exists && snapshot.data()!.containsKey('wordList')) {
    List<String> wordList = List<String>.from(snapshot.data()!['wordList']);
    return wordList;
  } else {
    return [];
  }
}


