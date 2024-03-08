import 'package:flutter/material.dart';

import '../models/database_manager.dart';
import 'wide_button.dart';

class SelectableGrid extends StatefulWidget {
  final List<String> displayList;
  final int crossAxisCount;
  final Color color;
  final Function(String)? onSelectionConfirmed;
  final String
      updateField; // New input to specify the field to update in the database

  const SelectableGrid({
    super.key,
    required this.displayList,
    this.crossAxisCount = 2,
    this.color = Colors.blue,
    this.onSelectionConfirmed,
    required this.updateField, // Ensure this parameter is required
  });

  @override
  SelectableGridState createState() => SelectableGridState();
}

class SelectableGridState extends State<SelectableGrid> {
  int? _selectedItemIndex;
  bool _isSelectionConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemCount: widget.displayList.length,
            itemBuilder: (context, index) {
              final bool isSelected = _selectedItemIndex == index;
              return GestureDetector(
                onTap: !_isSelectionConfirmed
                    ? () {
                        setState(() {
                          _selectedItemIndex = isSelected ? null : index;
                        });
                      }
                    : null,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : widget.color,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Text(
                    widget.displayList[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Visibility(
            visible: !_isSelectionConfirmed,
            child: WideButton(
              text: 'Vote',
              onPressed: () {
                if (_selectedItemIndex != null) {
                  setState(() {
                    _isSelectionConfirmed = true;
                  });
                  // Use the selected item's string to update the votingCham in the database
                  String selectedOption =
                      widget.displayList[_selectedItemIndex!];
                  // Assuming you have access to the player ID and room code
                  String playerId =
                      "..."; // You need to pass the actual player ID
                  String roomCode =
                      "..."; // You need to pass the actual room code

                  if (widget.updateField == "votingCham") {
                    DatabaseManager.setPlayerVotingCham(
                        roomCode, playerId, selectedOption);
                  }

                  if (widget.updateField == "votingTopic") {
                    DatabaseManager.setPlayerVotingTopic(
                        roomCode, playerId, selectedOption);
                  }

                  if (widget.onSelectionConfirmed != null) {
                    widget.onSelectionConfirmed!(selectedOption);
                  }
                }
              },
            ),
          ),
        ),
      ],
    ));
  }
}
