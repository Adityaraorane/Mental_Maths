import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmaths/services/api.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus for sharing functionality

class Level6 extends StatefulWidget {
  final int level;

  const Level6({Key? key, required this.level}) : super(key: key);

  @override
  _Level6State createState() => _Level6State();
}

class _Level6State extends State<Level6> {
  late int dividend;
  late int divisor;
  late int result;
  int currentStep = 0;
  String currentDisplay = '';
  TextEditingController answerController = TextEditingController();
  late List<String> steps;
  bool showAnswerBox = false;

  @override
  void initState() {
    super.initState();
    generateDivisionProblem();
  }

  void generateDivisionProblem() {
    Random random = Random();
    divisor = random.nextInt(90) + 10; // Random number between 10 and 99
    result = random.nextInt(90) + 10; // Random number between 10 and 99
    dividend = divisor * result; // Ensure the result is a whole number

    steps = [
      '', // Start with an empty string for the first step
      '$dividend',
      '÷',
      '$divisor',
    ];

    startDisplaySequence();
  }

  void startDisplaySequence() {
    // Reduced delay before showing the first number
    Future.delayed(const Duration(milliseconds: 500), () {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentStep < steps.length) {
          setState(() {
            currentDisplay = steps[currentStep];
            currentStep++;
          });
        } else {
          timer.cancel();
          setState(() {
            currentDisplay = '';
            showAnswerBox = true;
          });
        }
      });
    });
  }

  void checkAnswer() async {
    int userAnswer = int.tryParse(answerController.text) ?? 0;
    bool isCorrect = userAnswer == result;

    showDialog(
      context: context,
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isCorrect) {
                  setState(() {
                    generateDivisionProblem();
                  });
                }
              },
              child: Text(isCorrect ? 'Next Question' : 'Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rapid_fire'); // Return to Home
              },
              child: const Text('Return to Home'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level} - Division Challenge'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentDisplay,
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
              if (showAnswerBox)
                Column(
                  children: [
                    const SizedBox(height: 20),
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
