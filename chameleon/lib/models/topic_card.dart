class TopicCard {
  final String words;
  final int color;
  final String? imagePath;
  final List<String> wordList;

  TopicCard({
    required this.words, 
    required this.color, 
    this.imagePath,
    required this.wordList,
  });
}

final List<TopicCard> topicCards = [
  TopicCard(
    words: 'Animals',
    color: 0xFFCB997E,
    imagePath: 'assets/images/animals.png',
    wordList: ['Lion', 'Tiger', 'Bear', 'Elephant', 'Giraffe', 'Zebra', 'Fox', 'Wolf', 'Monkey', 'Deer'],
  ),
  TopicCard(
    words: 'Foods',
    color: 0xFFDDBEA9,
    imagePath: 'assets/images/foods.png',
    wordList: ['Pizza', 'Pasta', 'Sushi', 'Burger', 'Salad', 'Steak', 'Soup', 'Cake', 'Pie', 'Ice Cream'],
  ),
  TopicCard(
    words: 'Countries',
    color: 0xFFFFE8D6,
    wordList: ['USA', 'UK', 'Italy', 'Brazil', 'South Korea', 'Vietnam', 'China', 'France', 'Russia', 'Nigeria'],
  ),
  TopicCard(
    words: 'Jobs',
    color: 0xFFB7B7A4,
    imagePath: 'assets/images/jobs.png',
    wordList: ['Homeless', 'Drag Queen', 'Engineer', 'Professor', 'Streamer', 'Yapper', 'Barista', 'CEO', 'President', 'Cook'],
  ),
  TopicCard(
    words: 'People',
    color: 0xFFA5A58D,
    wordList: ['Ethan Dancho', 'Sherwin Wang', 'Sungmin Park', 'Joe Mama', 'Donald Trump', 'Kim Kardashian', 'Taylor Swift', 'Thomas Edison', 'MLK', 'Rosa Parks'],
  ),
  TopicCard(
    words: 'Restaurants',
    color: 0xFF6B705C,
    wordList: ['Wendys', 'Olive Garden', 'In-N-Out', 'LeeLees', 'KFC', 'McDonalds', 'Dennys', 'IHOP', 'Jade Palace', 'Shake Shack'],
  ),
  TopicCard(
    words: 'Sports',
    color: 0xFFe9edc9,
    wordList: ['Tennis', 'Pickelball', 'Football', 'Soccer', 'Basketball', 'Chess', 'Rugby', 'Track', 'Foozeball', 'Cricket'],
  ),
  TopicCard(
    words: 'Kpop Idols',
    color: 0xFFd6ccc2,
    wordList: ['Tzuyu', 'Chaewon', 'Jungkook', 'Jennie', 'Sakura', 'Momo', 'Sana', 'IU', 'Taehyung', 'Yuna'],
  ),
];

