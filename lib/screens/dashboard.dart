import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vmaths/screens/assignmnet_table.dart';
import 'package:vmaths/screens/login.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue.shade800,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              child: Text(
                'Mental Maths',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue.shade800),
              title: Text('Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Colors.blue.shade800),
              title: Text('Assign Question'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssignmentsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.blue.shade800),
              title: Text('Assignment Table'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssignmentTableScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue.shade800),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Mental Maths Dashboard!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
        ),
      ),
    );
  }
}

class UsersScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:5000/users'));

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color: Colors.blue.shade800);
            }
            if (snapshot.hasError) {
              return Text('Error fetching users', style: TextStyle(color: Colors.red));
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
                  title: Text('${user['firstName']} ${user['lastName']}', style: TextStyle(color: Colors.blue.shade900)),
                  subtitle: Text('Email: ${user['email']}'),
                );
              },
            );
          },
        ),
      ),
    );
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

  void _assignQuestion() async {
    final email = _emailController.text;
    final question = _questionController.text;
    final correctAnswer = _correctAnswerController.text;

    if (email.isEmpty || question.isEmpty || correctAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue.shade700),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment saved successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue.shade700),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save assignment', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Question'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.blue.shade700)),
            ),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Question', labelStyle: TextStyle(color: Colors.blue.shade700)),
            ),
            TextField(
              controller: _correctAnswerController,
              decoration: InputDecoration(labelText: 'Correct Answer', labelStyle: TextStyle(color: Colors.blue.shade700)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: _assignQuestion,
              child: Text('Assign Question'),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment Table'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
          onPressed: () {
            _showEmailInputDialog(context);
          },
          child: Text('View Assignment Insights'),
        ),
      ),
    );
  }

  void _showEmailInputDialog(BuildContext context) {
    final _emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter User Email', style: TextStyle(color: Colors.blue.shade800)),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter email address',
              hintStyle: TextStyle(color: Colors.blue.shade300),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.blue.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentInsights(
                      userEmail: _emailController.text,
                    ),
                  ),
                );
              },
              child: Text('View Insights'),
            ),
          ],
        );
      },
    );
  }
}
