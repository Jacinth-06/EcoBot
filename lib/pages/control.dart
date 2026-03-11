import 'dart:math';
import 'package:flutter/material.dart';

class WasteGame extends StatelessWidget {
  const WasteGame({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: const GamePage(),
    debugShowCheckedModeBanner: false,
  );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<WasteItem> items = [
    //WasteItem('Banana Peel', true, 'assets/images/banana.png'),
    WasteItem('Plastic Bottle', false, 'assets/images/bottle.jpeg'),
    WasteItem('Newspaper', true, 'assets/images/newspaper.jpeg'),
    //WasteItem('Metal Can', false, 'assets/images/can.webp'),
    WasteItem('Banana Peel', true, 'assets/images/banana peel.avif'),
    //WasteItem('Glass Bottle', false, 'assets/images/glass.png'),
  ];

  late List<WasteItem> gameItems;
  int index = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    gameItems = List.from(items)..shuffle(); // randomize
  }

  void _next(bool correct) {
    if (correct) score++;
    if (index + 1 >= gameItems.length) {
      _showEndDialog();
    } else {
      setState(() => index++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? '✅ Correct!' : '❌ Try Again'),
          backgroundColor: correct ? Colors.green : Colors.red,
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Your score: $score / ${gameItems.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                score = 0;
                index = 0;
                gameItems.shuffle();
              });
            },
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = gameItems[index];
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text('Score: $score'),
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Waste item image
          Draggable<WasteItem>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: Image.asset(item.image, width: 120),
            ),
            childWhenDragging: const SizedBox(height: 120),
            child: Image.asset(item.image, width: 120),
          ),
          const SizedBox(height: 40),

          // Bins row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildBin('Biodegradable', true, item, Colors.green.shade300),
              buildBin('Non-Biodegradable', false, item, Colors.blue.shade300),
            ],
          ),

          const SizedBox(height: 30),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(
              value: (index + 1) / gameItems.length,
              color: Colors.green,
              backgroundColor: Colors.green.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBin(String label, bool biodegradable, WasteItem current, Color color) {
    return DragTarget<WasteItem>(
      builder: (context, candidate, rejected) => Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(2, 3),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      onAccept: (w) => _next(w.isBiodegradable == biodegradable),
    );
  }
}

class WasteItem {
  final String name;
  final bool isBiodegradable;
  final String image;
  WasteItem(this.name, this.isBiodegradable, this.image);
}
