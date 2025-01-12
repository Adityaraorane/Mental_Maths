import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmaths/services/api.dart'; // Import the ApiService class

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
  ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    generateOperations();
  }

  void generateOperations() {
    Random random = Random();
    int numOperations = 1; // Only one multiplication operation
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

    if (userAnswer == result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Correct! +10 points')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Wrong! Correct answer: $result')),
      );
    }

    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question saved to database!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving question to database')),
      );
    }

    Navigator.pop(context);
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
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentDisplay.isNotEmpty)
                Text(
                  currentDisplay,
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                ),
              if (showAnswerBox)
                Column(
                  children: [
                    TextField(
                      controller: answerController,
                      decoration: InputDecoration(labelText: 'Enter your answer'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: checkAnswer,
                      child: Text('Submit Answer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
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
