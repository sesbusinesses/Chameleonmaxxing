import 'package:flutter/material.dart';
import 'package:chameleon/models/topic_card.dart';

class DetailPage extends StatelessWidget {
  final TopicCard topicCard;

  const DetailPage({super.key, required this.topicCard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topicCard.words),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Hero(
            tag: 'heroCard${topicCard.words}',
            child: Card(
              color: Color(topicCard.color ?? 0xFFFFE8D6),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      topicCard.words,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        // Removed NeverScrollableScrollPhysics to allow scrolling if necessary
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 5,
                          mainAxisSpacing: 80,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: topicCard.wordList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              topicCard.wordList[index],
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
