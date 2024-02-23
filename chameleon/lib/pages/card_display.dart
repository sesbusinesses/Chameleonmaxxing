import 'package:flutter/material.dart';
import 'package:chameleon/models/topic_card.dart';

class DetailPage extends StatelessWidget {
  final TopicCard topicCard;

  const DetailPage({super.key, required this.topicCard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Hero(
            tag: 'heroCard${topicCard.words}',
            child: Card(
              color: Color(topicCard.color),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    topicCard.words,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
