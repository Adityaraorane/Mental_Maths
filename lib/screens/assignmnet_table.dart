import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssignmentInsights extends StatefulWidget {
  final String userEmail;

  const AssignmentInsights({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AssignmentInsightsState createState() => _AssignmentInsightsState();
}

class _AssignmentInsightsState extends State<AssignmentInsights> {
  List<dynamic> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/assignments?email=${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _assignments = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load assignments')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment Insights'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? Center(child: Text('No assignments found'))
              : ListView.builder(
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _assignments[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          assignment['question'] ?? 'No Question',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Correct Answer: ${assignment['correctAnswer'] ?? 'N/A'}'),
                            Text('User Answer: ${assignment['userAnswer'] ?? 'Not Answered'}'),
                            Text('Created: ${DateTime.parse(assignment['createdAt']).toLocal()}'),
                            if (assignment['submittedAt'] != null)
                              Text('Submitted: ${DateTime.parse(assignment['submittedAt']).toLocal()}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}