import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Level7 extends StatefulWidget {
  final int level;

  const Level7({Key? key, required this.level}) : super(key: key);

  @override
  _Level7State createState() => _Level7State();
}

class _Level7State extends State<Level7> {
  late int num1;
  late int num2;
  late int hcf;
  int currentStep = 0;
  String currentDisplay = '';
  TextEditingController answerController = TextEditingController();
  late List<String> steps;
  bool showAnswerBox = false;

  @override
  void initState() {
    super.initState();
    generateHCFProblem();
  }

  void generateHCFProblem() {
    Random random = Random();
    num1 = random.nextInt(90) + 10; // Random number between 10 and 99
    num2 = random.nextInt(90) + 10; // Random number between 10 and 99
    hcf = calculateHCF(num1, num2); // Calculate the HCF

    steps = [
      'Find the HCF of these numbers',
      '', // Start with an empty string for the first step
      '$num1',
      '$num2',
    ];

    startDisplaySequence();
  }

  int calculateHCF(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
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
    bool isCorrect = userAnswer == hcf;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? '✅ Correct!' : '❌ Incorrect!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCorrect) Text('Correct Answer: $hcf'),
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
                    generateHCFProblem();
                  });
                }
              },
              child: Text(isCorrect ? 'Next Question' : 'Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home'); // Return to Home
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
        title: Text('Level ${widget.level} - HCF Challenge'),
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
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
