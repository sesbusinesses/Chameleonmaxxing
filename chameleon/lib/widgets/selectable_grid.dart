import 'package:flutter/material.dart';

import 'wide_button.dart';

class SelectableGrid extends StatefulWidget {
  final List<String> displayList;
  final int crossAxisCount;
  final Color color;
  final Function(String)? onSelectionConfirmed; // Callback for when a selection is confirmed

  const SelectableGrid({
    super.key,
    required this.displayList,
    this.crossAxisCount = 2,
    this.color = Colors.blue,
    this.onSelectionConfirmed,
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
                  onTap: !_isSelectionConfirmed ? () {
                    setState(() {
                      _selectedItemIndex = isSelected ? null : index;
                    });
                  } : null,
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
                    if (widget.onSelectionConfirmed != null) {
                      widget.onSelectionConfirmed!(widget.displayList[_selectedItemIndex!]);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      )
    );
  }
}
