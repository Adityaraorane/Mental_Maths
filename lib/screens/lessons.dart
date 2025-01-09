import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module 1: Introduction to Vedic Maths'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Introduction to Vedic Mathematics:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vedic Mathematics is an ancient system of mathematics that provides various techniques to solve mathematical problems more efficiently. The techniques are based on simple and effective mental calculation methods, making it easier for students to perform complex arithmetic operations mentally. The methods of Vedic Maths help in improving speed, accuracy, and memory, and are extremely helpful in competitive exams.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'In this module, you will learn the basics of Vedic Maths, including addition, subtraction, multiplication, and division. The aim is to improve mental calculation skills and develop a better understanding of numbers.',
              style: TextStyle(fontSize: 18),
            ),
            // Add any lesson-specific content here
          ],
        ),
      ),
    );
  }
}
