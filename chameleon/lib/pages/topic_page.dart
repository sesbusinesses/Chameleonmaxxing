import 'package:chameleon/widgets/card_list.dart';
import 'package:flutter/material.dart';

class TopicPage extends StatelessWidget {
  const TopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        // SafeArea should wrap the content you want to ensure is within the safe boundaries
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Your CardList widget here. Assuming it's a widget that can be directly used.
              Expanded(
                  child:
                      CardList()), // If CardList is scrollable, wrapping it in Expanded is usually a good idea
            ],
          ),
        ),
      ),
    );
  }
}
