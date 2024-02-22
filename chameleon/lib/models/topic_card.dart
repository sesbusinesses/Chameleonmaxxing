class TopicCard {
  final String words;
  final int color;
  final String? imagePath;

  TopicCard({
    required this.words, 
    required this.color, 
    this.imagePath,
  });
}

final List<TopicCard> topicCards = [
  TopicCard(words: 'Animals', color: 0xFFE29578, imagePath: 'assets/images/animals.png'),
  TopicCard(words: 'Food', color: 0xFFFFDDD2),
  TopicCard(words: 'Places', color: 0xFFEDF6F9),
  TopicCard(words: 'Things', color: 0xFF83C5BE),
  TopicCard(words: 'Animals', color: 0xFF006D77),
  TopicCard(words: 'Food', color: 0xFF0000FF),
  TopicCard(words: 'Places', color: 0xFFFF0000),
  TopicCard(words: 'Things', color: 0xFFFFFF00),
];

