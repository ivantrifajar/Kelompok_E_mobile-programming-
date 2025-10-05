import 'package:flutter/material.dart';

class StudentFlipMateriPage extends StatelessWidget {
  const StudentFlipMateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flip Materi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B8D4).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Di dalam aritmetika, ada beberapa operasi dasar yang sering digunakan, diantaranya penjumlahan, pengurangan, perkalian, dan pembagian.",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Next", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

