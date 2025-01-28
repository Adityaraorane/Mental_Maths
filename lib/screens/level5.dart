import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmaths/services/api.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus for sharing functionality

class Level5 extends StatefulWidget {
  final int level;

  const Level5({Key? key, required this.level}) : super(key: key);

  @override
  _Level5State createState() => _Level5State();
}

class _Level5State extends State<Level5> {
  List<String> operations = [];
  int result = 0;
  bool showAnswerBox = false;
  String currentDisplay = '';
  TextEditingController answerController = TextEditingController();
  int currentIndex = 0;
  int multiplier = 0;
  int divisor = 0;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    generateOperations();
  }

  void generateOperations() {
    Random random = Random();

    // Step 1: Generate 15 operations with + or -
    int currentValue = random.nextInt(9) + 1;
    operations.add(currentValue.toString());
    for (int i = 0; i < 15; i++) {
      String operation = random.nextBool() ? '+' : '-';
      int nextNum = random.nextInt(9) + 1;
      operations.add(operation);
      operations.add(nextNum.toString());
    }

    // Step 2: Multiply by a random number
    multiplier = random.nextInt(9) + 1;
    operations.add('*');
    operations.add(multiplier.toString());

    // Step 3: Divide by another random number (using ÷ instead of /)
    divisor = random.nextInt(9) + 1;
    operations.add('÷');
    operations.add(divisor.toString());

    // Step 4: Calculate the result of the expression
    result = int.parse(operations[0]);
    for (int i = 1; i < operations.length; i += 2) {
      int num = int.parse(operations[i + 1]);
      if (operations[i] == '+') {
        result += num;
      } else if (operations[i] == '-') {
        result -= num;
      } else if (operations[i] == '*') {
        result *= num;
      } else if (operations[i] == '÷') {
        result ~/= num; // Use integer division
      }
    }

    startDisplaySequence();
  }

  void startDisplaySequence() {
    // Reduced delay before showing the first number
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

  void shareScore() {
    Share.share('I scored $result in Level ${widget.level}! Can you beat my score? 🏆');
  }

  void checkAnswer() async {
    int userAnswer = int.tryParse(answerController.text) ?? 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('userEmail') ?? '';

    bool isSaved = await apiService.saveQuestion(
      widget.level,
      operations.join(' '),
      result,
      userAnswer,
      userEmail,
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
                Navigator.pushReplacementNamed(context, '/rapid_fire'); // Return to Home
              },
              child: const Text('Return to Home'),
            ),
          ],
        );
      },
    );

    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved to the database!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving question to the database.')),
      );
    }
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
