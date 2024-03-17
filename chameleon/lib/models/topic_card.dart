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

// Assume a global accessible Firestore instance
Future<List<TopicCard>> fetchTopicCards() async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('card_topics').get();
    List<TopicCard> topicCards = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Check if 'wordList' exists and is not null, otherwise provide an empty list as default
      List<String> wordList = data['wordList'] != null ? List<String>.from(data['wordList']) : [];
      // Similarly, provide default values for color and imagePath if they are null
      int color = data['color'] ?? 0xFFFFE8D6; // Default
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
    print("Error fetching topic cards: $e");
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
    print("Topic card added successfully");
  } catch (e) {
    print("Error adding topic card: $e");
  }
}

Future<void> deleteTopicCard(String topicId) async {
  try {
    // Deleting a document by ID
    await _firestore.collection('card_topics').doc(topicId).delete();
    print("Topic card deleted successfully");
  } catch (e) {
    print("Error deleting topic card: $e");
  }
}



