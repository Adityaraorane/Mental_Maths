import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.1.104:5000';

  Future<bool> signup(String firstName, String lastName, String dob, String mobile, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'dob': dob,
          'mobile': mobile,
          'email': email,
          'password': password,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> saveQuestion(int level, String question, int correctAnswer, int userAnswer, String userEmail) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/saveQuestion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'level': level,
        'question': question,
        'correctAnswer': correctAnswer,
        'userAnswer': userAnswer,
        'email': userEmail, // Pass the actual email of the logged-in user
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error saving question: $e');
    return false;
  }
}

// Fetch assignments by email
Future<List<Map<String, dynamic>>> getAssignmentsByEmail(String email) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/assignments?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> assignments = List<Map<String, dynamic>>.from(json.decode(response.body));
      return assignments;
    } else {
      throw Exception('Failed to load assignments');
    }
  } catch (e) {
    print('Error fetching assignments: $e');
    throw Exception('Failed to load assignments');
  }
}

Future<bool> incrementScore(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/incrementScore'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200;
  }

  Future<bool> saveUserAnswer(String email, String question, String userAnswer, String submittedAt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saveUserAnswer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'question': question,
        'userAnswer': userAnswer,
        'submittedAt': submittedAt,
      }),
    );

    return response.statusCode == 200;
  }
  

}