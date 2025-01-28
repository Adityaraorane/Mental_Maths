import 'package:flutter/material.dart';
import 'package:vmaths/screens/rapid_fire.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/Leaderboard.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Mental Maths App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/leaderboard': (context) => Leaderboard(),
        '/rapid_fire': (context) => RapidFireScreen(),
      },
    );
  }
}
