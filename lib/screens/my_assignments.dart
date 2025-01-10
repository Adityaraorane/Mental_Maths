import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmaths/services/api.dart';

class MyAssignmentsScreen extends StatefulWidget {
  @override
  _MyAssignmentsScreenState createState() => _MyAssignmentsScreenState();
}

class _MyAssignmentsScreenState extends State<MyAssignmentsScreen> {
  final ApiService _apiService = ApiService();
  String? userEmail;
  List<Map<String, dynamic>> assignments = [];
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail');
    });
    if (userEmail != null) {
      _fetchAssignments();
    }
  }

  Future<void> _fetchAssignments() async {
    try {
      final fetchedAssignments = await _apiService.getAssignmentsByEmail(userEmail!);
      setState(() {
        assignments = fetchedAssignments;
      });
    } catch (e) {
      print('Error fetching assignments: $e');
    }
  }

  Future<void> _submitAnswer(String question, String correctAnswer) async {
    String userAnswer = _answerController.text.trim();
    bool isCorrect = userAnswer == correctAnswer;
    String message = isCorrect ? 'Correct Answer!' : 'Wrong Answer, Try Again!';

    if (isCorrect) {
      await _apiService.saveUserAnswer(userEmail!, question, userAnswer, DateTime.now().toString());
      _fetchAssignments();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Assignments'),
      ),
      body: ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Question: ${assignment['question']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Enter your answer here',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _submitAnswer(
                      assignment['question'],
                      assignment['correctAnswer']
                    ),
                    child: Text('Submit Answer'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
