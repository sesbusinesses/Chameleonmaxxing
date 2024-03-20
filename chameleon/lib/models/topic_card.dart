// ignore_for_file: empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';

class TopicCard {
  final String words;
  final int? color; // Make color optional and nullable
  final String? imagePath; // Already optional and nullable
  final List<String> wordList;

  TopicCard({
    required this.words,
    this.color,
    this.imagePath,
    required this.wordList,
  });
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Define the colors you want to cycle through
final List<int> cycleColors = [
  0xFF00a5cf,
  0xFF9fffcb,
  0xFF25a18e,
  0xFF7ae582,
]; // Red, Blue, Green

Future<List<TopicCard>> fetchTopicCards() async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('card_topics').get();
    int colorIndex = 0; // This will help in cycling through colors
    List<TopicCard> topicCards = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> wordList =
          data['wordList'] != null ? List<String>.from(data['wordList']) : [];

      // Assign a color from cycleColors based on the current index, then increment the index
      int color = cycleColors[colorIndex % cycleColors.length];
      colorIndex++; // Move to the next color for the next card

      String? imagePath = data['imagePath'];
      return TopicCard(
        words: doc.id,
        color: color,
        imagePath: imagePath,
        wordList: wordList,
      );
    }).toList();
    return topicCards;
  } catch (e) {
    return [];
  }
}

Future<void> addTopicCard(TopicCard topicCard) async {
  try {
    // Creating a document with a specific ID (words)
    await _firestore.collection('card_topics').doc(topicCard.words).set({
      'color': topicCard.color,
      'imagePath': topicCard.imagePath,
      'wordList': topicCard.wordList,
    });
  } catch (e) {}
}

Future<void> deleteTopicCard(String topicId) async {
  try {
    // Deleting a document by ID
    await _firestore.collection('card_topics').doc(topicId).delete();
  } catch (e) {}
}
