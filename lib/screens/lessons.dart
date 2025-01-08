import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedic Maths Lessons'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.lightBlue[100],
            child: ListTile(
              title: Text('Lesson ${index + 1}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreenDetail(lessonNumber: index + 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LessonScreenDetail extends StatelessWidget {
  final int lessonNumber;

  const LessonScreenDetail({super.key, required this.lessonNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson $lessonNumber'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson $lessonNumber Content',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              'This is a placeholder for the lesson content. You can add theory and examples here later.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: LessonScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
