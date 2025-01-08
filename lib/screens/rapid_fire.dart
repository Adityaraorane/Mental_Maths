import 'package:flutter/material.dart';
import 'package:vmaths/screens/level1.dart';
//import 'package:vmaths/screens/level2.dart';
//import 'package:vmaths/screens/level3.dart';
import 'package:vmaths/screens/level4.dart';
//import 'package:vmaths/screens/level5.dart';
//import 'package:vmaths/screens/level6.dart';

class RapidFireScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rapid Fire Game"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Choose a Level",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _getLevelScreen(index + 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.all(24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Level ${index + 1}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLevelScreen(int level) {
    switch (level) {
      case 1:
        return Level1(level: level);
      //case 2:
        //return Level2(level: level);
      //case 3:
        //return Level3(level: level);
      case 4:
        return Level4(level: level);
      //case 5:
        //return Level5(level: level);
      //case 6:
        //return Level6(level: level);
      default:
        return Level1(level: 1);
    }
  }
}
