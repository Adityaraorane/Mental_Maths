import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmaths/services/api.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus for sharing functionality

class Level1 extends StatefulWidget {
  final int level;

  const Level1({Key? key, required this.level}) : super(key: key);

  @override
  _Level1State createState() => _Level1State();
}

class _Level1State extends State<Level1> {
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
    Random random = Random();
    int numOperations = random.nextInt(6) + 3;
    int currentValue = random.nextInt(9) + 1;
    List<String> ops = ['+', '-'];
    operations.add(currentValue.toString());

    for (int i = 0; i < numOperations; i++) {
      String operation = ops[random.nextInt(2)];
      int nextNum;
      do {
        nextNum = random.nextInt(9) + 1;
      } while (operations.contains('$operation$nextNum'));
      operations.add(operation);
      operations.add(nextNum.toString());
    }

    result = int.parse(operations[0]);
    for (int i = 1; i < operations.length; i += 2) {
      int num = int.parse(operations[i + 1]);
      result += (operations[i] == '+') ? num : -num;
    }

    startDisplaySequence();
  }

  void startDisplaySequence() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    generateOperations();
                  });
                },
                child: const Text('Play Again'),
              ),
            ],
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rapid_fire'); // Return to Home Button
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