import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Level3 extends StatefulWidget {
  final int level;

  const Level3({Key? key, required this.level}) : super(key: key);

  @override
  _Level3State createState() => _Level3State();
}

class _Level3State extends State<Level3> {
  List<String> operations = [];
  int result = 0;
  bool showAnswerBox = false;
  String currentDisplay = '';
  TextEditingController answerController = TextEditingController();
  int currentIndex = 0;
  int multiplier = 0;

  @override
  void initState() {
    super.initState();
    generateOperations();
  }

  void generateOperations() {
    Random random = Random();

    // Step 1: Determine the type of numbers (1-digit, 2-digit, or 3-digit)
    int numberType = random.nextInt(3); // 0: 1-digit, 1: 2-digit, 2: 3-digit
    int numberCount = 0;
    String numberRange = '';

    if (numberType == 0) {
      numberCount = 15; // 15 one-digit numbers
      numberRange = '1-digit';
    } else if (numberType == 1) {
      numberCount = 4; // 4 two-digit numbers
      numberRange = '2-digit';
    } else {
      numberCount = 3; // 3 three-digit numbers
      numberRange = '3-digit';
    }

    operations.clear();

    // Generate numbers and their operations (+ or -)
    for (int i = 0; i < numberCount; i++) {
      int number;
      if (numberRange == '1-digit') {
        number = random.nextInt(9) + 1; // 1-digit numbers
      } else if (numberRange == '2-digit') {
        number = random.nextInt(90) + 10; // 2-digit numbers
      } else {
        number = random.nextInt(900) + 100; // 3-digit numbers
      }

      operations.add(number.toString());

      if (i < numberCount - 1) {
        String operation = random.nextBool() ? '+' : '-';
        operations.add(operation);
      }
    }

    // Step 2: Multiply by a random 1- to 9-digit number (not 1)
    multiplier = random.nextInt(2) + 2; // Multiplier should be from 2 to 9
    operations.add('*');
    operations.add(multiplier.toString());

    // Step 3: Calculate the result of the expression
    result = int.parse(operations[0]);
    for (int i = 1; i < operations.length; i += 2) {
      int num = int.parse(operations[i + 1]);
      if (operations[i] == '+') {
        result += num;
      } else if (operations[i] == '-') {
        result -= num;
      } else if (operations[i] == '*') {
        result *= num;
      }
    }

    startDisplaySequence();
  }

  void startDisplaySequence() {
    // Start the sequence without showing the equation initially
    Future.delayed(const Duration(milliseconds: 500), () {
      Timer.periodic(const Duration(seconds: 1), (timer) {
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
    });
  }

  void checkAnswer() {
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
                    generateOperations();
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
        title: Text('Level ${widget.level} - Math Challenge'),
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
                style:
                    const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
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