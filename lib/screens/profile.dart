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

  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('userEmail');
    });
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    if (email == null) {
      throw Exception("Email is null");
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/profile?email=$email'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

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

  Future<void> _uploadProfileImage() async {
    if (_imageFile != null) {
      String base64Image = base64Encode(_imageFile!.readAsBytesSync());
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/updateProfile'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'email': email,
            'profileImage': base64Image,
            'points': 100,
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
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade800,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile photo with a border and shadow
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 90,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (user?['profileImage'] != null
                                  ? MemoryImage(base64Decode(user?['profileImage']))
                                  : AssetImage('assets/default_avatar.png')
                                      as ImageProvider),
                          backgroundColor: Colors.blue.shade100,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: FloatingActionButton(
                              backgroundColor: Colors.blue.shade600,
                              onPressed: _pickImage,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Name: ${user?['firstName']} ${user?['lastName']}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Email: ${user?['email']}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Mobile: ${user?['mobile'] ?? 'Not Available'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Date of Birth: ${user?['dob'] ?? 'Not Available'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Points: ${user?['points'] ?? 100}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
