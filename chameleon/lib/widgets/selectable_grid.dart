import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/wide_button.dart'; // Adjust the import path as necessary
import '../pages/reveal_page.dart'; // Ensure this import is correct

class SelectableGrid extends StatefulWidget {
  final List<String> displayList;
  final int crossAxisCount;
  final Color color;
  final String updateField; // 'votingCham' or 'votingTopic'
  final String roomCode;
  final String playerId;

  const SelectableGrid({
    super.key,
    required this.displayList,
    this.crossAxisCount = 2,
    this.color = Colors.blue,
    required this.updateField,
    required this.roomCode,
    required this.playerId,
  });

  @override
  SelectableGridState createState() => SelectableGridState();
}

class SelectableGridState extends State<SelectableGrid> {
  int? _selectedItemIndex;
  bool _isSelectionConfirmed = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialSelection();
  }

  void _fetchInitialSelection() async {
    String? initialSelection = await DatabaseManager.fetchInitialSelection(
        widget.roomCode, widget.playerId, widget.updateField);
    if (initialSelection != null &&
        widget.displayList.contains(initialSelection)) {
      setState(() {
        _selectedItemIndex = widget.displayList.indexOf(initialSelection);
        _isSelectionConfirmed = true; // Confirm selection if there's an initial one
      });
    }
  }

  Future<void> _tryToNavigateToRevealPage(BuildContext context) async {
    // Navigate to the RevealPage
    int votingChamTrueCount = await DatabaseManager.countPlayersVotingChamNotNull(widget.roomCode);
    int playersInRoomCount = await DatabaseManager.countPlayersInRoom(widget.roomCode);
    
    // Only navigate to Reveal page if updateField is 'votingCham' and if everyone voted.
    //TO-DO : right now it just navigate to reveal page even if not everyone has voted.
    if (widget.updateField == 'votingCham' &&
        votingChamTrueCount >= playersInRoomCount) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RevealPage(roomCode : widget.roomCode, playerId : widget.playerId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                onTap: _isSelectionConfirmed
                    ? null
                    : () {
                        setState(() {
                          _selectedItemIndex = index;
                        });
                      },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : widget.color,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
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
        if (!_isSelectionConfirmed) // Only show the vote button if no selection has been confirmed
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: WideButton(
              text: 'Vote',
              onPressed: () {
                if (_selectedItemIndex != null) {
                  setState(() {
                    _isSelectionConfirmed = true;
                  });
                  final selectedOption = widget.displayList[_selectedItemIndex!];
                  DatabaseManager.updatePlayerSelection(widget.roomCode, widget.playerId, widget.updateField, selectedOption).then((_) {
                    _tryToNavigateToRevealPage(context);
                  });
                }
              },
            ),
          ),
      ],
    );
  }
}
