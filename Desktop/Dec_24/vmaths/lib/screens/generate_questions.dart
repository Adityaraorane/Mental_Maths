import 'package:flutter/material.dart';
import 'game.dart';

class GenerateQuestionScreen extends StatefulWidget {
  const GenerateQuestionScreen({super.key});

  @override
  GenerateQuestionScreenState createState() => GenerateQuestionScreenState();
}

class GenerateQuestionScreenState extends State<GenerateQuestionScreen> {
  final TextEditingController _operationsController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  String _difficulty = 'Easy'; // Default difficulty

  void _startGame() {
    String operationsText = _operationsController.text.trim();
    String intervalText = _intervalController.text.trim();

    if (operationsText.isEmpty || intervalText.isEmpty) {
      _showErrorDialog('Please fill in all the fields.');
      return;
    }

    int? numOperations = int.tryParse(operationsText);
    int? timeInterval = int.tryParse(intervalText);

    if (numOperations == null || numOperations <= 0) {
      _showErrorDialog('Enter a valid number of operations.');
      return;
    }

    if (timeInterval == null || timeInterval <= 0) {
      _showErrorDialog('Enter a valid time interval.');
      return;
    }

    print('Navigating to GameScreen...');


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          numOperations: numOperations,
          timeInterval: timeInterval,
          difficulty: _difficulty, userEmail: 'widget.userEmail',
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Questions'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _operationsController,
              decoration: const InputDecoration(
                labelText: 'Number of Operations',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _intervalController,
              decoration: const InputDecoration(
                labelText: 'Time Interval (in seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _difficulty,
              items: ['Easy', 'Medium', 'Hard']
                  .map((difficulty) =>
                      DropdownMenuItem(value: difficulty, child: Text(difficulty)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _difficulty = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Difficulty Mode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
