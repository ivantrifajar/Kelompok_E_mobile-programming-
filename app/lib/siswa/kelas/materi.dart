import 'package:flutter/material.dart';

class MateriPage extends StatefulWidget {
  final String className;
  final Color classColor;
  final IconData classIcon;

  const MateriPage({
    super.key,
    required this.className,
    required this.classColor,
    required this.classIcon,
  });

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  int currentPage = 0;
  PageController pageController = PageController();

  // Sample material data with long descriptions
  late List<Map<String, dynamic>> materials;

  @override
  void initState() {
    super.initState();
    materials = [
      {
        'title': 'Pengenalan ${widget.className}',
        'subtitle': 'Dasar-dasar dan konsep fundamental',
        'icon': Icons.lightbulb,
        'duration': '15 menit',
        'pages': [
          {
            'title': 'Apa itu ${widget.className}?',
            'content': '''${widget.className} adalah mata pelajaran penting yang membantu mengembangkan kemampuan berpikir logis dan analitis.

Tujuan pembelajaran:
• Mengembangkan kemampuan berpikir kritis
• Melatih problem solving
• Membangun fondasi pengetahuan''',
          },
          {
            'title': 'Konsep Dasar',
            'content': '''Konsep dasar ${widget.className} meliputi:

1. Definisi dan Terminologi
2. Prinsip-prinsip Fundamental  
3. Hubungan Antar Elemen

Pemahaman konsep ini penting untuk pembelajaran selanjutnya.''',
          },
        ],
      },
      {
        'title': 'Teori dan Aplikasi',
        'subtitle': 'Memahami teori dan penerapannya',
        'icon': Icons.psychology,
        'duration': '20 menit',
        'pages': [
          {
            'title': 'Teori Fundamental',
            'content': '''Teori ${widget.className} adalah kerangka konseptual yang menjelaskan fenomena yang diamati.

Karakteristik teori yang baik:
• Dapat diuji dan diverifikasi
• Konsisten dengan data empiris
• Memiliki daya prediksi akurat''',
          },
        ],
      },
    ];
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.classColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Materi ${widget.className}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              // Handle bookmark
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with material selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.classColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: materials.asMap().entries.map((entry) {
                int index = entry.key;
                var material = entry.value;
                bool isSelected = index == currentPage;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPage = index;
                      });
                      pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            material['icon'],
                            color: isSelected ? widget.classColor : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            material['title'],
                            style: TextStyle(
                              color: isSelected ? widget.classColor : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Material content
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: materials.length,
              itemBuilder: (context, materialIndex) {
                return MaterialContentView(
                  material: materials[materialIndex],
                  classColor: widget.classColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialContentView extends StatefulWidget {
  final Map<String, dynamic> material;
  final Color classColor;

  const MaterialContentView({
    super.key,
    required this.material,
    required this.classColor,
  });

  @override
  State<MaterialContentView> createState() => _MaterialContentViewState();
}

class _MaterialContentViewState extends State<MaterialContentView> {
  int currentPageIndex = 0;
  PageController contentPageController = PageController();

  @override
  void dispose() {
    contentPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.material['pages'] as List<Map<String, dynamic>>;
    
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.material['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.classColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.classColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentPageIndex + 1}/${pages.length}',
                      style: TextStyle(
                        color: widget.classColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (currentPageIndex + 1) / pages.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(widget.classColor),
              ),
            ],
          ),
        ),
        // Content pages
        Expanded(
          child: PageView.builder(
            controller: contentPageController,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final page = pages[pageIndex];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    Text(
                      page['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Image placeholder
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: widget.classColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: widget.classColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 60,
                            color: widget.classColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            page['image'],
                            style: TextStyle(
                              color: widget.classColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Content text
                    Text(
                      page['content'],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Previous button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currentPageIndex > 0
                      ? () {
                          contentPageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Sebelumnya'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.classColor,
                    side: BorderSide(color: widget.classColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Next button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: currentPageIndex < pages.length - 1
                      ? () {
                          contentPageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () {
                          // Show completion dialog
                          _showCompletionDialog();
                        },
                  icon: Icon(
                    currentPageIndex < pages.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    currentPageIndex < pages.length - 1
                        ? 'Selanjutnya'
                        : 'Selesai',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.classColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration, color: widget.classColor),
              const SizedBox(width: 10),
              const Text(
                'Selamat!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Anda telah menyelesaikan materi ini dengan baik!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: widget.classColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      color: widget.classColor,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '+50 Poin',
                      style: TextStyle(
                        color: widget.classColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Lanjut Belajar',
                style: TextStyle(color: widget.classColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.classColor,
              ),
              child: const Text(
                'Kembali ke Kelas',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}