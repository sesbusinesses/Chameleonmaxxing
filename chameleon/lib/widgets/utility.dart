import 'package:flutter/material.dart';
import 'pop_up.dart'; // Make sure this import path is correct

// Display a message saying Warning
void showMessage(
  BuildContext context,
  String message,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) => PopUp(
      content: message,
      onOkPress: () => Navigator.of(context).pop(),
    ),
  );
}
