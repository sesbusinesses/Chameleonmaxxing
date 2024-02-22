import 'package:flutter/material.dart';

class RevealButton extends StatefulWidget {
  final String text;
  final String revealText;
  final Color color;

  const RevealButton({
    super.key,
    required this.text,
    required this.revealText,
    this.color = Colors.green,
  });

  @override
  State<RevealButton> createState() => _RevealButtonState();
}

class _RevealButtonState extends State<RevealButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          color: widget.color,
          child: Container(
            height: 66,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Center(
              child: Text(
                isPressed ? widget.revealText : widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
