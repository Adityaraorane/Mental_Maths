import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmaths/services/api.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus for sharing functionality

class Level4 extends StatefulWidget {
  final int level;

  const Level4({Key? key, required this.level}) : super(key: key);

  @override
  _Level4State createState() => _Level4State();
}

class _Level4State extends State<Level4> {
  List<String> operations = [];
  int result = 0;
  bool showAnswerBox = false;
  String currentDisplay = '';
  TextEditingController answerController = TextEditingController();
  int currentIndex = 0;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    generateOperations();
  }

  void generateOperations() {
    Random random = Random(); // Only one multiplication operation
    int num1 = random.nextInt(90) + 10; // Random two-digit number between 10 and 99
    int num2 = random.nextInt(90) + 10; // Random two-digit number between 10 and 99

    // Randomly decide if the numbers should be the same (for square case)
    if (random.nextBool()) {
      num2 = num1; // Make them the same for square operation
    }

    operations.add(num1.toString());
    operations.add('*');
    operations.add(num2.toString());

    // Calculate the result (multiplication)
    result = num1 * num2;

    startDisplaySequence();
  }

  void startDisplaySequence() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (currentIndex < operations.length) {
        setState(() {
          currentDisplay = operations[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          currentDisplay = '';
          showAnswerBox = true;
        });
      }
    });
  }

  void shareScore() {
    Share.share('I scored $result in Level ${widget.level}! Can you beat my score? 🏆');
  }

  void checkAnswer() async {
    int userAnswer = int.tryParse(answerController.text) ?? 0;

    // Retrieve the email from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('userEmail') ?? ''; // Default to empty string if email is not found

    // Save the question data to MongoDB
    bool isSaved = await apiService.saveQuestion(
      widget.level,
      operations.join(' '), // Join the operations into a single string
      result,
      userAnswer,
      userEmail,  // Use the email retrieved from SharedPreferences
    );

    bool isCorrect = userAnswer == result;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by clicking outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? '✅ Correct!' : '❌ Incorrect!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCorrect) Text('Correct Answer: $result'),
              const SizedBox(height: 20),
              Text(isCorrect ? 'Good job! 🎉' : 'Try again!'),
            ],
          ),
          actions: [
            if (isCorrect) ...[
              TextButton(
                onPressed: shareScore, // Share Button Functionality
                child: const Text('Share Score'),
              ),
            ],
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/rapid_fire'); // Change this route to your home route
              },
              child: const Text('Return to Home'),
            ),
          ],
        );
      },
    );

    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved to database!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving question to database')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentDisplay.isNotEmpty)
                Text(
                  currentDisplay,
                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                ),
              if (showAnswerBox)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.shade200, blurRadius: 8)
                        ],
                      ),
                      child: TextField(
                        controller: answerController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your answer',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'Submit Answer',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
