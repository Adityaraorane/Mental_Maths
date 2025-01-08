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


}