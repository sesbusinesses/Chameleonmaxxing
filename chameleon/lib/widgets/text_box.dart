import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText; // Declare obscureText here
  final Function(String)? onSubmitted;

  // Constructor
  const TextBox({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false, // Default value is set to false
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none, // Add this to remove underline
            ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText, // Correctly set obscureText here
            onSubmitted: onSubmitted,
          ),
        ),
      ),
    );
  }
}
