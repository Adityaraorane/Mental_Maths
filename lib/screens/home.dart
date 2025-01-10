import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'lessons.dart';
import 'about.dart';
import 'Leaderboard.dart';
import 'rapid_fire.dart';
import 'my_assignments.dart';  // Import the MyAssignments screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          'Mental Maths App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildCard('Welcome!', 'Start your journey towards mastering mental math.', Icons.school),
            _buildCard('Your Progress', 'Completed 3 out of 10 lessons', Icons.bar_chart),
            _buildCard('Leaderboard Rank', 'You are currently ranked #8!', Icons.leaderboard),
            _buildCard('Quick Challenge', 'Test your skills with a rapid fire round!', Icons.flash_on),
            _buildCard('My Assignments', 'Check your current and past assignments.', Icons.assignment),  // New Card
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade800),
            child: const Text(
              'Welcome to Mental Maths',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          _buildDrawerItem(Icons.school, 'Lessons', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LessonScreen()));
          }),
          _buildDrawerItem(Icons.leaderboard, 'Leaderboard', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Leaderboard()));
          }),
          _buildDrawerItem(Icons.lightbulb, 'Rapid Fire', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RapidFireScreen()));
          }),
          _buildDrawerItem(Icons.assignment, 'My Assignments', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyAssignmentsScreen()));  // New Item in Drawer
          }),
          _buildDrawerItem(Icons.info, 'About Us', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
          }),
          _buildDrawerItem(Icons.logout, 'Log Out', () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('userEmail');
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: onTap,
    );
  }

  Widget _buildCard(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue.shade900),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
