import 'package:flutter/material.dart';
import '../../services/materi_service.dart';

class MateriDetailPage extends StatefulWidget {
  final String materiId;
  final String judul;

  const MateriDetailPage({
    super.key,
    required this.materiId,
    required this.judul,
  });

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage> {
  final MateriService _materiService = MateriService();
  
  Map<String, dynamic>? _materiData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMateriDetail();
  }

  Future<void> _loadMateriDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _materiService.getMateriById(widget.materiId);

      print('=== MATERI DETAIL DEBUG ===');
      print('Result: $result');

      if (result['success'] == true && mounted) {
        setState(() {
          _materiData = result['data'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat detail materi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading materi detail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.judul,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur share akan segera tersedia'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : _materiData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Materi tidak ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1976D2).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              _materiData!['judul']?.toString() ?? 'Materi',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Description (if exists)
                            if (_materiData!['deskripsi'] != null && 
                                _materiData!['deskripsi'].toString().isNotEmpty) ...[
                              Text(
                                _materiData!['deskripsi'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Meta Info
                            Row(
                              children: [
                                Icon(
                                  _getTypeIcon(_materiData!['tipe_materi']?.toString() ?? 'teks'),
                                  size: 20,
                                  color: const Color(0xFF1976D2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTypeLabel(_materiData!['tipe_materi']?.toString() ?? 'teks'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1976D2),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Icon(
                                  Icons.visibility,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_materiData!['views'] ?? 0} views',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Teacher Info
                            if (_materiData!['guru_id'] != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'oleh ${(_materiData!['guru_id'] as Map<String, dynamic>?)!['nama_lengkap']?.toString() ?? 'Guru'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Content Section
                      const Text(
                        'Konten Materi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Content Body
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _materiData!['konten']?.toString() ?? 'Konten tidak tersedia',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // File URL (if exists)
                      if (_materiData!['file_url'] != null && 
                          _materiData!['file_url'].toString().isNotEmpty) ...[
                        const Text(
                          'File Lampiran',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attachment,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _materiData!['file_url'].toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Implement file download/open
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fitur download akan segera tersedia'),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.download,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Tags (if exists)
                      if (_materiData!['tags'] != null && 
                          (_materiData!['tags'] as List).isNotEmpty) ...[
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (_materiData!['tags'] as List).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF1976D2).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                tag.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1976D2),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  IconData _getTypeIcon(String tipeMateri) {
    switch (tipeMateri.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'dokumen':
        return Icons.description;
      case 'link':
        return Icons.link;
      case 'gambar':
        return Icons.image;
      default:
        return Icons.article;
    }
  }

  String _getTypeLabel(String tipeMateri) {
    switch (tipeMateri.toLowerCase()) {
      case 'video':
        return 'Video';
      case 'dokumen':
        return 'Dokumen';
      case 'link':
        return 'Link';
      case 'gambar':
        return 'Gambar';
      default:
        return 'Teks';
    }
  }
}
