import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<dynamic> players = [];

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/leaderboard'));
      if (response.statusCode == 200) {
        setState(() {
          players = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
  }

  Widget getMedal(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.emoji_events, color: Colors.yellow, size: 30);
      case 1:
        return Icon(Icons.emoji_events, color: Colors.grey, size: 30);
      case 2:
        return Icon(Icons.emoji_events, color: Colors.brown, size: 30);
      default:
        return SizedBox(width: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.blue,
      ),
      body: players.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    leading: getMedal(index),
                    title: Text(
                      '${players[index]['firstName']} ${players[index]['lastName']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '${players[index]['points']} Points',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
