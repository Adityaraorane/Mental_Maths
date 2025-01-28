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
  List<dynamic> allAssignments = []; // Define all assignments list
  List<dynamic> newAssignments = []; // Define new assignments list (unanswered)
  List<dynamic> answeredAssignments = []; // Define answered assignments list
  Map<String, TextEditingController> answerControllers = {};

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  @override
  void dispose() {
    // Clean up controllers
    answerControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
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
      if (userEmail == null) return;
      
      final fetchedAssignments = await _apiService.getAssignmentsByEmail(userEmail!);
      setState(() {
        allAssignments = fetchedAssignments;
        newAssignments = [];
        answeredAssignments = [];
        // Create controllers for each assignment and separate based on answered state
        allAssignments.forEach((assignment) {
          if (!answerControllers.containsKey(assignment['question'])) {
            answerControllers[assignment['question']] = TextEditingController();
          }

          // Check if the assignment is answered
          if (assignment['userAnswer'] == null) {
            newAssignments.add(assignment); // Unanswered assignments
          } else {
            answeredAssignments.add(assignment); // Answered assignments
          }
        });
      });
    } catch (e) {
      print('Error fetching assignments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load assignments. Please try again.'))
      );
    }
  }

  Future<void> _submitAnswer(String question, String correctAnswer) async {
    try {
      final controller = answerControllers[question];
      if (controller == null) return;
      
      String userAnswer = controller.text.trim();
      if (userAnswer.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter an answer'))
        );
        return;
      }

      bool success = await _apiService.saveUserAnswer(
        userEmail!,
        question,
        userAnswer,
        DateTime.now().toString()
      );

      if (success) {
        if (userAnswer == correctAnswer) {
          // Increment score on the backend
          await _apiService.incrementScore(userEmail!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Correct Answer! Score incremented by 5'))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong Answer, Try Again!'))
          );
        }
        controller.clear();
        await _fetchAssignments(); // Refresh the assignments list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answer. Please try again.'))
        );
      }
    } catch (e) {
      print('Error submitting answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Assignments'),
      ),
      body: ListView(
        children: [
          if (newAssignments.isNotEmpty)
            ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('New Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...newAssignments.map((assignment) {
                final controller = answerControllers[assignment['question']] ?? TextEditingController();
                
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question: ${assignment['question']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Enter your answer here',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _submitAnswer(
                            assignment['question'],
                            assignment['correctAnswer'],
                          ),
                          child: Text('Submit Answer'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          
          if (answeredAssignments.isNotEmpty)
            ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Previous Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...answeredAssignments.map((assignment) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question: ${assignment['question']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Previous Answer: ${assignment['userAnswer']}',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
        ],
      ),
    );
  }
}
