import 'package:flutter/material.dart';

class DisplayGrid extends StatelessWidget {
  final List<String> userList;
  final List<bool> hasVoted; // New list of booleans
  final int crossAxisCount;
  final Color trueColor; // Color for items with true boolean value
  final Color falseColor; // Color for items with false boolean value

  DisplayGrid({
    super.key,
    required this.userList,
    List<bool>? hasVoted,
    this.crossAxisCount = 2,
    this.trueColor = Colors.green,
    this.falseColor = Colors.blue,
  }) : hasVoted = hasVoted ?? List<bool>.filled(userList.length, true); // Default to all true if not provided

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  // Determine color based on the boolean value
                  Color itemColor = hasVoted[index] ? trueColor : falseColor;
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: itemColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      userList[index],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                },
                childCount: userList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
