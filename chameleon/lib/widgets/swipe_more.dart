import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingText extends StatefulWidget {
  const FloatingText({super.key});

  @override
  FloatingTextState createState() => FloatingTextState();
}

class FloatingTextState extends State<FloatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String text = "Swipe to see more →";
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: text
              .split('')
              .map((letter) => _buildAnimatedLetter(letter))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAnimatedLetter(String letter) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double offset = math.sin(_controller.value * 2 * math.pi) * 10;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Text(
            letter,
            style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }
}

