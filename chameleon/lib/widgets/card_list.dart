import 'package:flutter/material.dart';
import 'package:chameleon/pages/card_display.dart';
import 'package:chameleon/models/topic_card.dart';

const itemSize = 150.0;

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  final scrollController = ScrollController(); // Add a ScrollController

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: CustomScrollView(
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
                    final difference = scrollController.offset - itemPosition;
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
                          transform: Matrix4.identity()..scale(scale, 1.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(topicCard: topicCard)),
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
                                  color: Color(topicCard.color),
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              topicCard.words,
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign
                                                  .left, // Align text to the left
                                            ),
                                          ),
                                        ),
                                        if (topicCard.imagePath != null)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                  } else {
                    return null;
                  }
                },
                childCount: topicCards.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
