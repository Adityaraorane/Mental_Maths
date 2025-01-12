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
  List<dynamic> assignments = []; // Define assignments list
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

  // Add the missing _fetchAssignments method
  Future<void> _fetchAssignments() async {
    try {
      if (userEmail == null) return;
      
      final fetchedAssignments = await _apiService.getAssignmentsByEmail(userEmail!);
      setState(() {
        assignments = fetchedAssignments;
        // Create controllers for each assignment
        assignments.forEach((assignment) {
          if (!answerControllers.containsKey(assignment['question'])) {
            answerControllers[assignment['question']] = TextEditingController();
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

      // Attempt to parse the user answer as an integer
      int? userAnswerInt = int.tryParse(userAnswer);
      
      // If the parsing fails (user didn't input a valid number), show a message and return
      if (userAnswerInt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid integer answer'))
        );
        return;
      }

      // Call the API service to save the user's answer
      bool success = await _apiService.saveUserAnswer(
        userEmail!,
        question,
        userAnswerInt,  // Passing the integer value instead of the string
      );

      if (success) {
        // Check if the user's answer is correct
        bool isCorrect = userAnswerInt.toString() == correctAnswer;
        String message = isCorrect ? 'Correct Answer!' : 'Wrong Answer, Try Again!';

        // Display appropriate feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message))
        );

        if (isCorrect) {
          // Clear the controller and fetch the assignments again if the answer is correct
          controller.clear();
          await _fetchAssignments(); // Refresh the assignments list
        }
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
      body: assignments.isEmpty
          ? Center(child: Text('No assignments available'))
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
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
                        if (assignment['userAnswer'] != null)
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
              },
            ),
    );
  }
}