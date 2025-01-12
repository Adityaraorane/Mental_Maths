import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.1.104:5000'; // Ensure this URL is correct for your backend

  // Existing methods
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
          'email': userEmail, 
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error saving question: $e');
      return false;
    }
  }

  Future<bool> updateUserScore(String email, int score) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/updateUserScore'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'score': score,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating score: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getQuestions'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<bool> deleteUserAccount(String email) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteUser'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Define the missing methods

  // Method to fetch assignments for a user by email
  Future<List<Map<String, dynamic>>> getAssignmentsByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getAssignmentsByEmail/$email'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }

  // Method to save the user's answer to an assignment
  Future<bool> saveUserAnswer(String email, String assignmentId, int userAnswer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saveUserAnswer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'assignmentId': assignmentId,
          'userAnswer': userAnswer,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error saving user answer: $e');
      return false;
    }
  }
}
