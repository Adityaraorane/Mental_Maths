import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vmaths/services/api.dart';

class GameScreen extends StatefulWidget {
  final int numOperations;
  final int timeInterval;
  final String difficulty;
  final String userEmail; // Add user email for score tracking

  const GameScreen({
    Key? key,
    required this.numOperations,
    required this.timeInterval,
    required this.difficulty,
    required this.userEmail,
  }) : super(key: key);

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late Timer _timer;
  late List<String> _expressionParts;
  late int _correctAnswer;
  late String _currentPart;
  int _step = 0;
  double _opacity = 0.0;
  bool _showAnswerInput = false;
  final TextEditingController _answerController = TextEditingController();

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final result = await compute(_generateExpression, widget);
    setState(() {
      _expressionParts = result['expressionParts'] as List<String>;
      _correctAnswer = result['correctAnswer'] as int;
      _currentPart = "";
      _showAnswerInput = false;
      _answerController.clear(); // Clear previous input
    });

    // Send question and correct answer to the server
    await _apiService.saveQuestion(_expressionParts.join(" "), _correctAnswer);

    _startTimer();
  }

  static Map<String, dynamic> _generateExpression(GameScreen widget) {
    final random = Random();
    int result = random.nextInt(20) - 10; // Allow negative starting numbers
    final parts = [result.toString()];

    final operators = ['+', '-', '*', '/'];
    final usedOperators = <String>{};

    for (int i = 0; i < widget.numOperations; i++) {
      String operator = operators[random.nextInt(4)];
      usedOperators.add(operator);

      int nextNumber = random.nextInt(20) - 10; // Allow negative numbers

      // Special handling for division to avoid division by zero
      if (operator == '/' && nextNumber == 0) {
        nextNumber = random.nextInt(9) + 1;
      }

      parts.add(operator);
      parts.add(nextNumber.toString());

      switch (operator) {
        case '+':
          result += nextNumber;
          break;
        case '-':
          result -= nextNumber;
          break;
        case '*':
          result *= nextNumber;
          break;
        case '/':
          result = (result / nextNumber).truncate(); // Ensure integer division
          break;
      }
    }

    return {
      'expressionParts': parts,
      'correctAnswer': result,
    };
  }

  void _startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: widget.timeInterval),
      (timer) {
        if (_step < _expressionParts.length) {
          setState(() {
            _currentPart = _expressionParts[_step];
            _opacity = 1.0;
          });

          Future.delayed(
            Duration(milliseconds: widget.timeInterval * 800),
            () {
              setState(() {
                _opacity = 0.0;
              });
            },
          );

          _step++;
        } else {
          timer.cancel();
          setState(() {
            _currentPart = "Your Turn!";
            _showAnswerInput = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Challenge'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: Text(
                _currentPart,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _showAnswerInput
                ? Column(
                    children: [
                      TextField(
                        controller: _answerController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Your Answer',
                          labelStyle: TextStyle(fontSize: 18),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(signed: true),
                        onSubmitted: (value) => _checkAnswer(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        child: const Text('Submit Answer'),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _checkAnswer() async {
    // Get the value from the controller
    String trimmedValue = _answerController.text.trim();

    // Check if the value is empty
    if (trimmedValue.isEmpty) {
      _showResultDialog(
        context,
        'Invalid Input',
        'Please enter a number.',
      );
      return;
    }

    try {
      // Parse the user answer as an integer (now allows negative numbers)
      final userAnswer = int.parse(trimmedValue);

      // Debug print statements
      print('Correct Answer: $_correctAnswer');
      print('User Answer: $userAnswer');

      // Compare the user's answer with the correct answer
      if (userAnswer == _correctAnswer) {
        // Update user score
        bool scoreUpdated = await _apiService.updateUserScore(
          widget.userEmail, 
          5
        );

        _showResultDialog(
          context, 
          'Correct!', 
          'You solved the math problem!\nScore updated: +5 points'
        );
      } else {
        _showResultDialog(
          context,
          'Wrong Answer!',
          'Correct Answer: $_correctAnswer',
        );
      }
    } catch (e) {
      // This catch block will handle non-numeric inputs
      print('Error parsing input: $e');
      _showResultDialog(
        context,
        'Invalid Input',
        'Please enter a valid whole number.',
      );
    }
  }

  void _showResultDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          title, 
          style: TextStyle(
            color: title == 'Correct!' ? Colors.green : Colors.red
          )
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(ctx).pop();
              // Reset the game
              _initializeGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              _shareResult(content);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _shareResult(String content) {
    Share.share(
      'Check out my Math Challenge result: $content', 
      subject: 'My Math Challenge Score'
    );
  }
}