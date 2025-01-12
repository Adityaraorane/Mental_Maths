import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Import the http package
import 'dart:convert';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Users and Assignments
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.blue.shade800,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Assignments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Users
            Center(
              child: FutureBuilder<List<Map<String, dynamic>>>(  
                future: fetchUsers(),  // Fetch users from the API
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error fetching users');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No users found');
                  }

                  final users = snapshot.data!;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text('${user['firstName']} ${user['lastName']}'),
                        subtitle: Text('Email: ${user['email']}'),
                      );
                    },
                  );
                },
              ),
            ),
            // Tab 2: Assignments
            Center(
              child: AssignmentsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // Function to fetch users from API
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:5000/users'));

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

class AssignmentsScreen extends StatefulWidget {
  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final _emailController = TextEditingController();
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();

  // Function to handle assignment submission
  void _assignQuestion() async {
    final email = _emailController.text;
    final question = _questionController.text;
    final correctAnswer = _correctAnswerController.text;

    if (email.isEmpty || question.isEmpty || correctAnswer.isEmpty) {
      // Show error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:5000/assignments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'question': question,
        'correctAnswer': correctAnswer,
      }),
    );

    if (response.statusCode == 200) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment saved successfully')),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save assignment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _questionController,
            decoration: InputDecoration(labelText: 'Question'),
          ),
          TextField(
            controller: _correctAnswerController,
            decoration: InputDecoration(labelText: 'Correct Answer'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _assignQuestion,
            child: Text('Assign Question'),
          ),
        ],
      ),
    );
  }
}
