import 'package:flutter/material.dart';

class PopUp extends StatelessWidget {
  final String content;
  final VoidCallback onOkPress;

  const PopUp({
    super.key,
    required this.content,
    required this.onOkPress,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          //fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
          onPressed: onOkPress,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
