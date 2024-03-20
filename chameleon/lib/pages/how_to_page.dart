import 'package:flutter/material.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Rules'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: const <Widget>[
            Text(
              'How To Play',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. Objective \n Aim to either uncover the Alien (for Humans) or guess the secret word or image without being exposed as the Alien (for the Alien).',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '2. Starting the Game \n A player initiates a game room and becomes the host. Other players join using the provided Code. In the waiting room, players select their desired topic. The game starts once the host initiates it.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '3. Game Play for All Players \n All players, except for the Alien, check the secret word. Decide the starting player and everyone take turn to give a clue about the secret word.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '4. Game Play for Humans \n Give a clue that’s related to the secret word without being too revealing. Discuss the clues to deduce who the Alien might be, then cast your votes based on these discussions.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '5. Game Play for the Alien \n Blend into the conversation by paying close attention to other players\' clues. Without revealing your lack of knowledge, guess the secret word based on these clues. Remember, do not vote for yourself!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '6. Rules \n Avoid showing your screen to others or looking at others’ screens. Keep the secret word and your role a mystery.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '7. Winning the Game \n Humans win by identifying the Alien without leaking the secret word. The Alien wins if they remain undetected or guess the secret word correctly.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '8. Scoring \n Alien escapes 2 points for the Alien, none for others. Alien caught but guesses the word: 1 point for the Alien. Alien caught without guessing the word: 2 points for Humans.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '9. Tips \n For Humans, think creatively with your clues to avoid being obvious. For Aliens, stay composed and pretend to know the secret word.',
              style: TextStyle(fontSize: 18),
            ),
            // Add more rules as needed
          ],
        ),
      ),
    );
  }
}
