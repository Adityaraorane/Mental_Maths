import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000'; // Ensure this URL is correct for your backend

  // Signup Method
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

  // Login Method
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

  // Save Question Method
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

  // Update User Score Method
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

  // Fetch Questions Method
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

  // Delete User Account Method
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

  // Fetch Assignments for a User by Email Method
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

  // Save User Answer to an Assignment Method
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

  // Simple login with the email received from Google OAuth
  Future<bool> loginWithGoogle(String email, String firstName, String lastName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google-login'),  // Adjust the URL to match your backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          }), // Only send email for login
      );

      if (response.statusCode == 200) {
        return true;  // Login was successful
      } else {
        print('Failed response: ${response.body}');
        return false;  // Login failed (non-200 status code)
      }
    } catch (e) {
      print('Google login error: $e');
      return false;  // Return false in case of any error
    }
  }
}