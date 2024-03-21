// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:chameleon/pages/card_display.dart';
import 'package:chameleon/models/topic_card.dart';
// Add this import

const itemSize = 150.0;

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  final scrollController = ScrollController(); // Add a ScrollController
  Future<List<TopicCard>> futureTopicCards =
      fetchTopicCards(); // Fetch topic cards asynchronously

  void onListen() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onListen); // Add listener to the controller
  }

  @override
  void dispose() {
    scrollController.removeListener(
        onListen); // Remove listener when the widget is disposed
    super.dispose();
  }

  void _showAddTopicCardDialog(BuildContext context) {
    // Controllers for text fields
    TextEditingController topicController = TextEditingController();
    List<TextEditingController> wordControllers =
        List.generate(16, (_) => TextEditingController());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Topic'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: topicController,
                decoration: const InputDecoration(hintText: 'Topic Name'),
              ),
              ...List.generate(
                  16,
                  (index) => TextField(
                        controller: wordControllers[index],
                        decoration:
                            InputDecoration(hintText: 'Word ${index + 1}'),
                      )),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              // Prepare data for the new TopicCard
              String topicName = topicController.text;
              List<String> wordList =
                  wordControllers.map((controller) => controller.text).toList();
              int defaultColor = 0xFFFFE8D6;
              TopicCard newCard = TopicCard(
                  words: topicName, color: defaultColor, wordList: wordList);

              // Call addTopicCard method
              addTopicCard(newCard).then((_) {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  futureTopicCards = fetchTopicCards(); // Refresh the list
                });
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<TopicCard>>(
          future: futureTopicCards,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final topicCards = snapshot.data!;
                return CustomScrollView(
                  controller: scrollController,
                  slivers: <Widget>[
                    const SliverAppBar(
                      title: Text('Topics'),
                      pinned: true,
                      backgroundColor: Colors.transparent,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < topicCards.length) {
                            final topicCard = topicCards[index];
                            final itemPosition = index * itemSize;
                            final difference =
                                scrollController.offset - itemPosition;
                            final percent = 1 - (difference / (itemSize / 2));
                            double opacity = percent;
                            double scale = percent;
                            if (opacity > 1.0) opacity = 1.0;
                            if (opacity < 0.0) opacity = 0.0;
                            if (percent > 1.0) scale = 1.0;

                            return Align(
                              heightFactor: 0.8,
                              child: Opacity(
                                opacity: opacity,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(scale, 1.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                topicCard: topicCard)),
                                      );
                                    },
                                    child: Hero(
                                        tag:
                                            'heroCard${topicCard.words}', // Ensure each card has a unique tag, topicCard.id should be unique
                                        child: Card(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                          color: Color(
                                              topicCard.color ?? 0xFFFFE8D6),
                                          child: SizedBox(
                                            height: itemSize,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween, // Space between items
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center, // Center items vertically
                                              children: <Widget>[
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Text(
                                                      topicCard.words,
                                                      style: const TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign
                                                          .left, // Align text to the left
                                                    ),
                                                  ),
                                                ),
                                                if (topicCard.imagePath != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                      topicCard.imagePath!,
                                                      width: 100,
                                                      fit: BoxFit
                                                          .cover, // This ensures the image covers the width but maintains its aspect ratio
                                                    ),
                                                  ),
                                                // Optionally, you can add an 'else' block to display a default image or widget
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            );
                          } else if (index == topicCards.length) {
                            // Button for adding a new topic card, with space before it
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0), // Adjust the padding as needed
                              // child: Center(
                              //   child: IconButton(
                              //     icon: const Icon(Icons.add_circle_outline,
                              //         size: 50),
                              //     onPressed: () =>
                              //         _showAddTopicCardDialog(context),
                              //   ),
                              // ),
                            );
                          }
                          return null;
                        },
                        childCount: topicCards.length + 1,
                      ),
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error fetching topics: ${snapshot.error}'));
              }
            }
            // While data is loading
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}


// Assuming fetchTopicCards() is defined elsewhere and returns Future<List<TopicCard>>