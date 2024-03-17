import 'package:flutter/material.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How To Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: const <Widget>[
            Text(
              'How To Use This App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Step one: download this app',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '2. Step two: play',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '3. Step three: have fun',
              style: TextStyle(fontSize: 18),
            ),
            // Add more steps as needed
          ],
        ),
      ),
    );
  }
}
