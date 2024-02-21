import 'package:flutter/material.dart';
import '../widgets/wide_button.dart';
import '../widgets/text_box.dart';
import 'waiting_page.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextBox(
              hintText: 'Enter join code', // Updated hint text
              controller: _nameController, // Pass the controller here
            ),
            WideButton(
              text: 'Join Game', // Updated button text
              onPressed: () {
                // Here, you might want to handle the join game logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WaitingPage()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: WideButton(
          text: 'Cancel',
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose(); // Dispose the controller
    super.dispose();
  }
}
