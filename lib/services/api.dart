import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:5000';

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

  // Save the question and correct answer to the server
  Future<bool> saveQuestion(String question, int correctAnswer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saveQuestion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'question': question,
          'correctAnswer': correctAnswer.toString(), // Convert to string for server compatibility
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Save question error: $e');
      return false;
    }
  }

  // Update user score
Future<bool> updateUserScore(String userEmail, int points) async {
  try {
    // Add timeout to prevent hanging
    final response = await http.post(
      Uri.parse('your_api_endpoint'),
      body: {
        'email': userEmail,
        'points': points.toString()
      },
    ).timeout(
      const Duration(seconds: 10), // const is used here because Duration is a compile-time constant
      onTimeout: () {
        print('Connection timed out');
        return http.Response('Timeout', 408);
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update score. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating score: $e');
    return false;
  }
}
}