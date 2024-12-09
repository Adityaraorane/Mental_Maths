import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:5000';

  Future<bool> signup(String firstName, String lastName, String dob, String mobile, String email, String password) async {
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
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    return response.statusCode == 200;
  }

  // Save the question and correct answer to the server
  Future<bool> saveQuestion(String question, int correctAnswer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saveQuestion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'question': question,
        'correctAnswer': correctAnswer,
      }),
    );

    return response.statusCode == 200;
  }

  // Update user score
  Future<void> updateUserScore(int scoreIncrement) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateScore'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'scoreIncrement': scoreIncrement}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update score');
    }
  }
}
