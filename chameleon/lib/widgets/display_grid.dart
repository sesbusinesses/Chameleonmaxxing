import 'package:flutter/material.dart';

class DisplayGrid extends StatelessWidget {
  final List<String> userList;
  final List<bool> hasVoted;
  final int crossAxisCount;
  final Color trueColor;
  final Color falseColor;

  DisplayGrid({
    super.key,
    required this.userList,
    List<bool>? hasVoted,
    this.crossAxisCount = 2,
    this.trueColor = Colors.green,
    this.falseColor = const Color.fromARGB(255, 82, 82, 82),
  }) : hasVoted = hasVoted ?? List<bool>.filled(userList.length, true);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                Color itemColor = hasVoted[index] ? trueColor : falseColor;
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: itemColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      userList[index],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              childCount: userList.length,
            ),
          ),
        ),
      ],
    );
  }
}
