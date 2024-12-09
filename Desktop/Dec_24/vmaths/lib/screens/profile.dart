import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    loadEmail();
  }

  // Load email from SharedPreferences
  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('userEmail');
    });
  }

  // Function to fetch user profile from the backend
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/profile?email=$email'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadProfileImage();
    }
  }

  // Upload the image to the backend
  Future<void> _uploadProfileImage() async {
    if (_imageFile != null) {
      String base64Image = base64Encode(_imageFile!.readAsBytesSync());
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/updateProfile'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'email': email,
            'profileImage': base64Image,
            'points': 100, // Initialize score to 100
          }),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile photo updated successfully')),
          );
        } else {
          throw Exception('Failed to update profile photo');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (email == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available.'));
          }

          var user = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo circle
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (user?['profileImage'] != null
                                ? MemoryImage(
                                    base64Decode(user?['profileImage']))
                                : AssetImage('assets/default_avatar.png')
                                    as ImageProvider),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Name: ${user?['firstName']} ${user?['lastName']}'),
                Text('Email: ${user?['email']}'),
                Text('Mobile: ${user?['mobile']}'),
                Text('Date of Birth: ${user?['dob']}'),
                const SizedBox(height: 20),
                Text('Points: ${user?['points'] ?? 100}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
