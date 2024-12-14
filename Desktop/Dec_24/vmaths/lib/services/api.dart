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
  Future<bool> updateUserScore(String email, int scoreIncrement) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/updateScore'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'scoreIncrement': scoreIncrement,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update score error: $e');
      return false;
    }
  }
}