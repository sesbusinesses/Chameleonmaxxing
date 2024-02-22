import 'package:flutter/material.dart';
import '../widgets/selectable_grid.dart';
import '../widgets/wide_button.dart';

class WaitingTopicsPage extends StatelessWidget {
  const WaitingTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SelectableGrid(
            displayList: ['topic1', 'topic2', 'topic3', 'topic4'], // Example usernames
            color: Colors.grey,
          ),
          const SizedBox(height: 40),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 40),
          //   child: WideButton(
          //     text: 'Cancel',
          //     color: Colors.red,
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
        ],
      ),
    );
  }
}
