import 'package:flutter/material.dart';
import 'flashcard_detail.dart';

class FlashcardTab extends StatefulWidget {
  final List<Map<String, dynamic>> flashcardList;
  final bool isLoading;
  
  const FlashcardTab({
    super.key,
    required this.flashcardList,
    required this.isLoading,
  });

  @override
  State<FlashcardTab> createState() => _FlashcardTabState();
}

class _FlashcardTabState extends State<FlashcardTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flashcard Tersedia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: widget.isLoading
                ? _buildLoadingGrid()
                : widget.flashcardList.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: widget.flashcardList.length,
                        itemBuilder: (context, index) {
                          final flashcard = widget.flashcardList[index];
                          final colors = [
                            const Color(0xFF1976D2),
                            const Color(0xFF64B5F6),
                            const Color(0xFF42A5F5),
                            const Color(0xFF90CAF9),
                            const Color(0xFFBBDEFB),
                            const Color(0xFFE3F2FD),
                          ];
                          final color = colors[index % colors.length];
                          return _buildFlashcardItem(flashcard, color);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardItem(Map<String, dynamic> flashcard, Color color) {
    final judul = flashcard['judul']?.toString() ?? 'Flashcard';
    final topik = flashcard['topik']?.toString() ?? '';
    final jumlahKartu = flashcard['jumlahKartu'] ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardDetailPage(
                  flashcard: flashcard,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.style,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(height: 8),
                Text(
                  judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (topik.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    topik,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '$jumlahKartu kartu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada flashcard tersedia',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Flashcard akan muncul setelah guru membuat flashcard untuk kelas Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}