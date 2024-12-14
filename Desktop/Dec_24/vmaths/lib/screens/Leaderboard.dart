import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];

  // Fetch leaderboard from API
  Future<void> fetchLeaderboard() async {
    final String url = 'http://localhost:5000/leaderboard'; // Your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          leaderboard = json.decode(response.body);
        });
      } else {
        print('Error fetching leaderboard. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: leaderboard.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                    backgroundColor: Colors.amberAccent,
                  ),
                  title: Text(
                    user['username'] ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Score: ${user['score'] ?? 0}'),
                  trailing: Icon(
                    Icons.star,
                    color: index == 0 ? Colors.yellow : Colors.grey,
                  ),
                );
              },
            ),
    );
  }
}
