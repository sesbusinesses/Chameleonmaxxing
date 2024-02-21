import 'package:flutter/material.dart';
import 'package:chameleon/widgets/topic_card.dart'; // Ensure this path is correct

const itemSize = 150.0;

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {

  final scrollController = ScrollController(); // Add a ScrollController

  void onListen(){
    setState(() {
    });
  }

  @override
  void initState() {
    topicCards.addAll(List.from(topicCards));
    super.initState();
    scrollController.addListener(onListen); // Add listener to the controller
  }

  @override
  void dispose() {
    scrollController.removeListener(onListen); // Remove listener when the widget is disposed
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
                  // Ensure the index is within the range of topicCards
                  if (index < topicCards.length) {
                    final topicCard = topicCards[index];
                    final itemPosition = index * itemSize; // Calculate the position of the item
                    final difference = scrollController.offset - itemPosition;
                    final percent = 1 - (difference / (itemSize/2));
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
                          child: Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            color: Color(topicCard.color), // Correct the color usage
                            child: SizedBox(
                              height: itemSize, // Use itemSize if needed for sizing
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Center content
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      topicCard.words,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return null; // Return null for indices outside the list range
                  }
                },
                childCount: topicCards.length, // Define the number of children in the list
              ),
            ),
          ],
        ),
      ),
    );
  }
}
