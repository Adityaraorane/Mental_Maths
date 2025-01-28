import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vmaths/services/api.dart';

class Level8 extends StatefulWidget {
  final int level;
  const Level8({Key? key, required this.level}) : super(key: key);

  @override
  _Level8State createState() => _Level8State();
}

class _Level8State extends State<Level8> {
  List<int> numbers = [];
  int hcf = 0;
  bool showAnswerBox = false;
  String currentDisplay = '';
  TextEditingController answerController = TextEditingController();
  late Timer timer;
  int currentIndex = 0;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    generateNumbers();
  }

  void generateNumbers() {
    Random random = Random();
    int numCount = random.nextInt(3) + 3; // Generate between 3 to 5 numbers
    numbers.clear();

    // Generate random numbers between 10 to 999
    for (int i = 0; i < numCount; i++) {
      numbers.add(random.nextInt(990) + 10);
    }

    // Calculate HCF of the numbers
    hcf = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
      hcf = _calculateHCF(hcf, numbers[i]);
    }

    // Ensure HCF is not 1 or 0
    if (hcf == 1 || hcf == 0) {
      generateNumbers();  // Regenerate numbers if HCF is 1 or 0
    } else {
      startDisplaySequence();
    }
  }

  int _calculateHCF(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  void startDisplaySequence() {
    setState(() {
      currentDisplay = 'Calculate the HCF of the following numbers:';
    });

    // Display numbers one by one with a 1-second delay
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentIndex < numbers.length) {
        setState(() {
          currentDisplay = 'Calculate the HCF of the following numbers:\n' +
              numbers.sublist(0, currentIndex + 1).join(', ');
        });
        currentIndex++;
      } else {
        timer.cancel();
        setState(() {
          showAnswerBox = true;
        });
      }
    });
  }

  void checkAnswer() async {
    int userAnswer = int.tryParse(answerController.text) ?? 0;
    bool isCorrect = userAnswer == hcf;

    // Assuming you have a way to retrieve the logged-in user's email
    String userEmail = 'user@example.com'; // Replace this with the actual logged-in user's email

    // Save the question to the database
    bool isSaved = await apiService.saveQuestion(
      widget.level,
      numbers.join(', '),
      hcf,
      userAnswer,
      userEmail,  // Pass the logged-in user's email
    );

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
                Navigator.pushNamed(context, '/rapid_fire'); // Return to Home
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
  void dispose() {
    timer.cancel();
    super.dispose();
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
              Text(
                currentDisplay,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (showAnswerBox)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Submit Answer'),
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
