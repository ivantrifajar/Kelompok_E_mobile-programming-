import 'package:flutter/material.dart';

class FlashcardDetailPage extends StatefulWidget {
  final Map<String, dynamic> flashcard;

  const FlashcardDetailPage({
    super.key,
    required this.flashcard,
  });

  @override
  State<FlashcardDetailPage> createState() => _FlashcardDetailPageState();
}

class _FlashcardDetailPageState extends State<FlashcardDetailPage> {
  int _currentCardIndex = 0;
  bool _showAnswer = false;
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _cards = (widget.flashcard['kartu'] as List? ?? [])
        .map((card) => card as Map<String, dynamic>)
        .toList();
  }

  void _nextCard() {
    if (_currentCardIndex < _cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showAnswer = false;
      });
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _showAnswer = false;
      });
    }
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final judul = widget.flashcard['judul']?.toString() ?? 'Flashcard';
    final topik = widget.flashcard['topik']?.toString() ?? '';
    final deskripsi = widget.flashcard['deskripsi']?.toString() ?? '';

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1976D2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            judul,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Flashcard ini belum memiliki kartu',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _cards[_currentCardIndex];
    final pertanyaan = currentCard['pertanyaan']?.toString() ?? '';
    final jawaban = currentCard['jawaban']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          judul,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentCardIndex + 1}/${_cards.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (topik.isNotEmpty) ...[
                    Text(
                      topik,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (deskripsi.isNotEmpty) ...[
                    Text(
                      deskripsi,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Progress Indicator
                  LinearProgressIndicator(
                    value: (_currentCardIndex + 1) / _cards.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Card
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleAnswer,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _showAnswer ? const Color(0xFF4CAF50) : const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_showAnswer ? const Color(0xFF4CAF50) : const Color(0xFF1976D2)).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showAnswer ? Icons.lightbulb : Icons.help_outline,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _showAnswer ? 'Jawaban' : 'Pertanyaan',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _showAnswer ? jawaban : pertanyaan,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap untuk ${_showAnswer ? 'melihat pertanyaan' : 'melihat jawaban'}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Navigation Buttons
                  Row(
                    children: [
                      // Previous Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentCardIndex > 0 ? _previousCard : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Sebelumnya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Next Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentCardIndex < _cards.length - 1 ? _nextCard : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Selanjutnya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
