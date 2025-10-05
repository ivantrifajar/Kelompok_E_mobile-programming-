import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardViewPage extends StatefulWidget {
  final List<dynamic> flashcards;
  const FlashcardViewPage({super.key, required this.flashcards});

  @override
  State<FlashcardViewPage> createState() => _FlashcardViewPageState();
}

class _FlashcardViewPageState extends State<FlashcardViewPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
  }

  void _flipCard() {
    if (!mounted) return;
    setState(() {
      _isFlipped = !_isFlipped;
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        if (_isFlipped) _flipCard(); // Balikkan kartu ke depan saat berganti
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua kartu telah selesai!")));
    }
  }
  
  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
         if (_isFlipped) _flipCard(); // Balikkan kartu ke depan saat berganti
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Flashcard")),
        body: const Center(child: Text("Tidak ada kartu di topik ini.")),
      );
    }
    
    final currentCard = widget.flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Kartu ${_currentIndex + 1}/${widget.flashcards.length}")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = _controller.value * pi;
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle);
                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        height: 350,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        // Tampilkan sisi depan atau belakang berdasarkan animasi
                        child: Transform(
                           transform: Matrix4.identity()..rotateY(angle > pi / 2 ? pi : 0),
                           alignment: Alignment.center,
                           child: Text(
                            angle > pi / 2 ? currentCard['answer']! : currentCard['question']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                           ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousCard,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  child: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: _nextCard,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

