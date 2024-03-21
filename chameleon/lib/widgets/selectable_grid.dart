import 'package:flutter/material.dart';
import '../models/database_manager.dart';
import '../widgets/wide_button.dart';

class SelectableGrid extends StatefulWidget {
  final List<String> displayList;
  final int crossAxisCount;
  final Color color;
  final String updateField; // 'votingCham' or 'votingTopic'
  final String roomCode;
  final String playerId;

  const SelectableGrid({
    Key? key,
    required this.displayList,
    this.crossAxisCount = 2,
    this.color = Colors.blue,
    required this.updateField,
    required this.roomCode,
    required this.playerId,
  }) : super(key: key);

  @override
  SelectableGridState createState() => SelectableGridState();
}

class SelectableGridState extends State<SelectableGrid>
    with SingleTickerProviderStateMixin {
  int? _selectedItemIndex;
  bool _isSelectionConfirmed = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fetchInitialSelection();
  }

  Future<void> _fetchInitialSelection() async {
    String? initialSelection = await DatabaseManager.fetchInitialSelection(
      widget.roomCode,
      widget.playerId,
      widget.updateField,
    );
    if (initialSelection != null &&
        widget.displayList.contains(initialSelection)) {
      setState(() {
        _selectedItemIndex = widget.displayList.indexOf(initialSelection);
        _isSelectionConfirmed = true;
      });
    }
  }

  void _updateSelection(int index) {
    if (!_isSelectionConfirmed) {
      DatabaseManager.updatePlayerSelection(
        widget.roomCode,
        widget.playerId,
        widget.updateField,
        widget.displayList[index],
      ).then((_) => _animationController.forward());
      setState(() {
        _selectedItemIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                onTap: () => _updateSelection(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : widget.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.displayList[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        if (!_isSelectionConfirmed)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: WideButton(
              text: 'Vote',
              onPressed: () {
                if (_selectedItemIndex != null) {
                  setState(() {
                    _isSelectionConfirmed = true;
                  });
                  final selectedOption =
                      widget.displayList[_selectedItemIndex!];
                  DatabaseManager.updatePlayerSelection(widget.roomCode,
                          widget.playerId, widget.updateField, selectedOption)
                      .then((_) {
                    if (widget.updateField == 'votingCham' ||
                        widget.updateField == 'chamGuess') {
                      DatabaseManager.updateVoteNum(widget.roomCode);
                    }
                  });
                }
              },
            ),
          ),
      ],
    );
  }
}
