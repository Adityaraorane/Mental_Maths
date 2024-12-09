import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart'; // For sharing functionality
import 'package:vmaths/services/api.dart'; // Import the API service for making HTTP requests

class GameScreen extends StatefulWidget {
  final int numOperations;
  final int timeInterval;
  final String difficulty;

  const GameScreen({
    Key? key,
    required this.numOperations,
    required this.timeInterval,
    required this.difficulty,
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

  final ApiService _apiService = ApiService(); // API service instance

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
    });

    // Send question and correct answer to the server
    await _apiService.saveQuestion(_expressionParts.join(" "), _correctAnswer);

    _startTimer();
  }

  static Map<String, dynamic> _generateExpression(GameScreen widget) {
    final random = Random();
    int result = random.nextInt(10) + 1;
    final parts = [result.toString()];

    final operators = ['+', '-', '*', '/'];
    final usedOperators = <String>{};

    for (int i = 0; i < widget.numOperations; i++) {
      String operator;
      do {
        operator = operators[random.nextInt(4)];
      } while (i >= operators.length - 1 && !usedOperators.contains(operator));

      usedOperators.add(operator);
      int nextNumber;
      do {
        nextNumber = random.nextInt(10) + 1;
      } while (operator == '/' && nextNumber == 0);

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
          result ~/= nextNumber;
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
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Game'),
      ),
      body: Center(
        child: Padding(
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (value) async {
                  try {
                    final userAnswer = int.parse(value);
                    if (userAnswer == _correctAnswer) {
                      await _apiService.updateUserScore(5); // Increment score by 5
                      _showResultDialog(context, 'Correct!', 'You won!');
                    } else {
                      _showResultDialog(
                          context, 'Wrong Answer!', 'Correct Answer: $_correctAnswer');
                    }
                  } catch (e) {
                    _showResultDialog(
                        context, 'Error', 'Please enter a valid number.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
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

  void _resetGame() {
    setState(() {
      _step = 0;
      _opacity = 0.0;
    });
    _initializeGame();
  }

  void _shareResult(String content) {
    Share.share(content, subject: 'Math Game Result');
  }
}
