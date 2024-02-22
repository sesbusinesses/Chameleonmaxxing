import 'package:flutter/material.dart';

class DisplayGrid extends StatelessWidget {
  final List<String> displayList;
  final int crossAxisCount;

  const DisplayGrid({
    super.key, 
    required this.displayList,
    this.crossAxisCount = 2, // Set the default value to 2
    });

  @override
  Widget build(BuildContext context) {
    // Wrap the CustomScrollView in a Flexible widget
    return Flexible(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Determines the number of columns
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                childAspectRatio: 2, // Adjust the aspect ratio of the grid items
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      displayList[index],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                },
                childCount: displayList.length, // The total number of grid items
              ),
            ),
          ),
        ],
      ),
    );
  }
}
