import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Maths Lessons'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Addition'),
            _buildSectionContent(
                'Addition is the process of combining two or more numbers to find their total.'),
            _buildSectionContent('Example:\n 12 + 8 = 20'),
            _buildSectionTips([
              'Break numbers into smaller parts for easier addition.',
              'Add from left to right to speed up calculations.',
            ]),
            _buildSectionTitle('Subtraction'),
            _buildSectionContent(
                'Subtraction is finding the difference between two numbers.'),
            _buildSectionContent('Example:\n 15 - 7 = 8'),
            _buildSectionTips([
              'Think of subtraction as "how much more to reach the larger number".',
              'Use complements to simplify large subtractions.',
            ]),
            _buildSectionTitle('Multiplication'),
            _buildSectionContent(
                'Multiplication is the process of repeated addition of a number.'),
            _buildSectionContent('Example:\n 6 × 4 = 24'),
            _buildSectionTips([
              'Learn multiplication tables up to 12 for quicker calculations.',
              'Break large numbers into smaller factors for easier multiplication.',
            ]),
            _buildSectionTitle('Division'),
            _buildSectionContent(
                'Division is splitting a number into equal parts or groups.'),
            _buildSectionContent('Example:\n 20 ÷ 4 = 5'),
            _buildSectionTips([
              'Think of division as repeated subtraction.',
              'Remember basic division facts for faster calculations.',
            ]),
            _buildSectionTitle('HCF and LCM'),
            _buildSectionContent(
                'HCF (Highest Common Factor) is the largest factor common to two numbers, while LCM (Least Common Multiple) is the smallest number divisible by both.'),
            _buildSectionContent('Example:\n Numbers: 12, 18\nHCF: 6\nLCM: 36'),
            _buildSectionTips([
              'Use prime factorization to find HCF and LCM.',
              'For smaller numbers, list factors and multiples to determine them.',
            ]),
            _buildSectionTitle('Tips and Tricks for Fast Calculations'),
            _buildSectionContent(
                '1. Use rounding to simplify calculations and adjust later.\n'
                '2. Practice estimating results for quick approximations.\n'
                '3. Use patterns in numbers to simplify operations.'),
            _buildSectionTitle('Vedic Maths'),
            _buildSectionContent(
                'Vedic Maths is an ancient Indian system of mathematics that offers shortcuts for solving problems.'),
            _buildSectionContent(
                'Example:\nMultiply 97 × 96\n\nStep 1: Subtract each from 100.\n97 → 3, 96 → 4\nStep 2: Multiply the differences: 3 × 4 = 12\nStep 3: Subtract the sum of differences from 100: 100 - (3 + 4) = 93\nResult: 9312'),
            _buildSectionTips([
              'Learn sutras like Nikhilam (for multiplication) and Paravartya (for division).',
              'Practice regularly to apply them effectively.',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
      ),
    );
  }

  Widget _buildSectionTips(List<String> tips) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(fontSize: 16.0, color: Colors.black87),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 16.0, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
