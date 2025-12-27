import 'package:flutter/material.dart';
import '../../services/siswa_service.dart';
import '../../services/kelas_service.dart';
import '../../services/flashcard_service.dart';

class ProgressSiswaPage extends StatefulWidget {
  const ProgressSiswaPage({super.key});

  @override
  State<ProgressSiswaPage> createState() => _ProgressSiswaPageState();
}

class _ProgressSiswaPageState extends State<ProgressSiswaPage> {
  final SiswaService _siswaService = SiswaService();
  final KelasService _kelasService = KelasService();
  final FlashcardService _flashcardService = FlashcardService();

  String _selectedKelas = 'Semua Kelas';
  String _selectedFilter = 'Semua';

  List<Map<String, dynamic>> _siswaList = [];
  List<Map<String, dynamic>> _kelasList = [];
  List<Map<String, dynamic>> _flashcardList = [];
  bool _isLoading = true;
  int _totalSiswa = 0;
  double _averageProgress = 0.0;

  // TODO: Get actual guru_id from user session/auth
  final String _guruId = '68e630667aa27040bcb95fed';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadKelas();
      await _loadFlashcards();
      await _loadSiswa();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadKelas() async {
    try {
      final result = await _kelasService.getAllKelas(guruId: _guruId);

      if (result['success'] == true) {
        final dataList = result['data'] as List? ?? [];
        setState(() {
          _kelasList = dataList.map<Map<String, dynamic>>((kelas) {
            final kelasMap = kelas as Map<String, dynamic>? ?? {};
            return {
              '_id': kelasMap['_id']?.toString() ?? '',
              'nama': kelasMap['nama']?.toString() ?? '',
              'tahun_ajaran': kelasMap['tahun_ajaran']?.toString() ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading kelas: $e');
    }
  }

  Future<void> _loadFlashcards() async {
    try {
      List<Map<String, dynamic>> allFlashcards = [];

      // Get flashcards for each class
      for (final kelas in _kelasList) {
        final kelasId = kelas['_id']?.toString();
        if (kelasId != null) {
          final result = await _flashcardService.getFlashcardsByClass(
            kelasId: kelasId,
            isActive: true,
          );

          if (result['success'] == true) {
            final flashcards = result['data'] as List? ?? [];
            for (final flashcard in flashcards) {
              final flashcardMap = flashcard as Map<String, dynamic>? ?? {};
              allFlashcards.add({
                '_id': flashcardMap['_id']?.toString() ?? '',
                'judul': flashcardMap['judul']?.toString() ?? '',
                'kelas_id': kelasId,
                'kelas_nama': kelas['nama']?.toString() ?? '',
                'jumlahKartu': flashcardMap['jumlahKartu'] ?? 0,
                'kartu': flashcardMap['kartu'] ?? [],
              });
            }
          }
        }
      }

      setState(() {
        _flashcardList = allFlashcards;
      });

      print('Loaded ${_flashcardList.length} flashcards for progress tracking');
    } catch (e) {
      print('Error loading flashcards: $e');
    }
  }

  Future<void> _loadSiswa() async {
    try {
      List<Map<String, dynamic>> allSiswa = [];
      Map<String, Map<String, dynamic>> progressMap = {};

      // Get siswa for each class
      for (final kelas in _kelasList) {
        final kelasId = kelas['_id']?.toString();
        if (kelasId != null) {
          final result = await _siswaService.getSiswaByKelas(kelasId);

          if (result['success'] == true) {
            final siswaList = result['data'] as List? ?? [];
            for (final siswa in siswaList) {
              final siswaMap = siswa as Map<String, dynamic>? ?? {};
              final userData =
                  siswaMap['user_id'] as Map<String, dynamic>? ?? {};
              final siswaId = siswaMap['_id']?.toString() ?? '';

              // Calculate flashcard progress for this student
              final progressData = _calculateFlashcardProgress(
                siswaId,
                kelasId,
              );

              allSiswa.add({
                '_id': siswaId,
                'nama_lengkap': userData['nama_lengkap']?.toString() ?? 'Siswa',
                'email': userData['email']?.toString() ?? '',
                'kelas_nama': kelas['nama']?.toString() ?? '',
                'kelas_id': kelasId,
                'progress': progressData['percentage'],
                'flashcards_completed': progressData['completed'],
                'total_flashcards': progressData['total'],
                'last_activity': _generateRandomActivity(),
              });

              // Store progress data for this student
              progressMap[siswaId] = progressData;
            }
          }
        }
      }

      // Remove duplicates based on siswa ID and merge progress from multiple classes
      final uniqueSiswa = <String, Map<String, dynamic>>{};
      for (final siswa in allSiswa) {
        final id = siswa['_id']?.toString();
        if (id != null && id.isNotEmpty) {
          if (uniqueSiswa.containsKey(id)) {
            // Merge progress from multiple classes
            final existing = uniqueSiswa[id]!;
            final existingCompleted = existing['flashcards_completed'] as int;
            final existingTotal = existing['total_flashcards'] as int;
            final newCompleted = siswa['flashcards_completed'] as int;
            final newTotal = siswa['total_flashcards'] as int;

            final totalCompleted = existingCompleted + newCompleted;
            final totalFlashcards = existingTotal + newTotal;
            final newProgress = totalFlashcards > 0
                ? (totalCompleted / totalFlashcards) * 100
                : 0.0;

            uniqueSiswa[id] = {
              ...existing,
              'progress': newProgress,
              'flashcards_completed': totalCompleted,
              'total_flashcards': totalFlashcards,
              'kelas_nama': '${existing['kelas_nama']}, ${siswa['kelas_nama']}',
            };
          } else {
            uniqueSiswa[id] = siswa;
          }
        }
      }

      final siswaList = uniqueSiswa.values.toList();

      // Calculate statistics
      final totalSiswa = siswaList.length;
      final averageProgress = siswaList.isEmpty
          ? 0.0
          : siswaList
                    .map((s) => s['progress'] as double)
                    .reduce((a, b) => a + b) /
                siswaList.length;

      setState(() {
        _siswaList = siswaList;
        _totalSiswa = totalSiswa;
        _averageProgress = averageProgress;
      });

      print(
        'Loaded $_totalSiswa siswa with average progress ${_averageProgress.toStringAsFixed(1)}%',
      );
    } catch (e) {
      print('Error loading siswa: $e');
    }
  }

  // Calculate flashcard progress for a specific student and class
  Map<String, dynamic> _calculateFlashcardProgress(
    String siswaId,
    String kelasId,
  ) {
    // Get flashcards for this specific class
    final classFlashcards = _flashcardList
        .where((fc) => fc['kelas_id'] == kelasId)
        .toList();

    if (classFlashcards.isEmpty) {
      return {'completed': 0, 'total': 0, 'percentage': 0.0};
    }

    // For demo purposes, simulate flashcard completion
    // In real implementation, this would query a student_progress table or similar
    final totalFlashcards = classFlashcards.length;

    // Simulate completion based on student ID and flashcard ID for consistency
    int completedCount = 0;
    for (final flashcard in classFlashcards) {
      final flashcardId = flashcard['_id'] ?? '';
      // Create a pseudo-random but consistent completion status
      final combinedHash = (siswaId + flashcardId).hashCode.abs();
      final completionChance = (combinedHash % 100) / 100.0;

      // 70% chance of completion for more realistic progress
      if (completionChance < 0.7) {
        completedCount++;
      }
    }

    final percentage = totalFlashcards > 0
        ? (completedCount / totalFlashcards) * 100
        : 0.0;

    return {
      'completed': completedCount,
      'total': totalFlashcards,
      'percentage': percentage,
    };
  }

  // Helper functions to generate demo data
  String _generateRandomActivity() {
    final activities = [
      '2 jam yang lalu',
      '1 hari yang lalu',
      '3 jam yang lalu',
      '5 jam yang lalu',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % activities.length;
    return activities[random];
  }

  List<Map<String, dynamic>> get _filteredSiswa {
    List<Map<String, dynamic>> filtered = _siswaList;

    // Filter by class
    if (_selectedKelas != 'Semua Kelas') {
      print('Filtering by class: $_selectedKelas');
      filtered = filtered.where((siswa) {
        final kelasNama = siswa['kelas_nama']?.toString() ?? '';
        final matches = kelasNama.contains(_selectedKelas);
        print('Student: ${siswa['nama_lengkap']}, Class: $kelasNama, Matches: $matches');
        return matches;
      }).toList();
      print('Filtered students count: ${filtered.length}');
    }

    // Sort by progress based on selected filter
    print('Sorting by: $_selectedFilter');
    if (_selectedFilter == 'Tertinggi') {
      // Sort by progress (highest first)
      filtered.sort(
        (a, b) => (b['progress'] as double).compareTo(a['progress'] as double),
      );
      print('Sorted by highest progress first');
    } else if (_selectedFilter == 'Terendah') {
      // Sort by progress (lowest first)
      filtered.sort(
        (a, b) => (a['progress'] as double).compareTo(b['progress'] as double),
      );
      print('Sorted by lowest progress first');
    } else {
      // For 'Semua', keep original order (no additional sorting)
      print('No sorting applied (original order)');
    }

    return filtered;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1))
          .toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Siswa',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantau perkembangan belajar siswa Anda',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.people,
                            title: 'Total Siswa',
                            value: _isLoading ? '-' : _totalSiswa.toString(),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.trending_up,
                            title: 'Rata-rata',
                            value: _isLoading
                                ? '-'
                                : '${_averageProgress.toStringAsFixed(0)}%',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedKelas,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF1976D2),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Semua Kelas',
                              child: Text('Semua Kelas'),
                            ),
                            ..._kelasList
                                .map(
                                  (kelas) => DropdownMenuItem<String>(
                                    value: kelas['nama'],
                                    child: Text(
                                      '${kelas['nama']} (${kelas['tahun_ajaran']})',
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedKelas = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color(0xFF1976D2),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Semua',
                            child: Text('Semua'),
                          ),
                          DropdownMenuItem(
                            value: 'Tertinggi',
                            child: Text('Tertinggi'),
                          ),
                          DropdownMenuItem(
                            value: 'Terendah',
                            child: Text('Terendah'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSiswa.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada siswa',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredSiswa.length,
                    itemBuilder: (context, index) {
                      final siswa = _filteredSiswa[index];
                      final initials = _getInitials(siswa['nama_lengkap']);
                      final completedFlashcards =
                          siswa['flashcards_completed'] as int;
                      final totalFlashcards = siswa['total_flashcards'] as int;

                      return _buildStudentProgressCard(
                        name: siswa['nama_lengkap'],
                        kelas: siswa['kelas_nama'],
                        progress: (siswa['progress'] as double) / 100,
                        completedTasks: completedFlashcards,
                        totalTasks: totalFlashcards,
                        avatar: initials,
                        rank: index + 1,
                        lastActivity: siswa['last_activity'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          value == '-'
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          Text(title, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStudentProgressCard({
    required String name,
    required String kelas,
    required double progress,
    required int completedTasks,
    required int totalTasks,
    required String avatar,
    required int rank,
    required String lastActivity,
  }) {
    Color rankColor = rank <= 3 ? const Color(0xFF1976D2) : Colors.grey;
    IconData rankIcon = rank == 1
        ? Icons.emoji_events
        : rank == 2
        ? Icons.workspace_premium
        : rank == 3
        ? Icons.military_tech
        : Icons.person;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            _showStudentDetail(
              name,
              kelas,
              progress,
              completedTasks,
              totalTasks,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Rank Badge
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: rank <= 3
                            ? Icon(rankIcon, color: rankColor, size: 20)
                            : Text(
                                '#$rank',
                                style: TextStyle(
                                  color: rankColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF1976D2),
                      child: Text(
                        avatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Student Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  lastActivity,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getProgressColor(progress).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(progress),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Task Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Flashcard Selesai: $completedTasks/$totalTasks',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Lihat Detail →',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _showStudentDetail(
    String name,
    String kelas,
    double progress,
    int completed,
    int total,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              kelas,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Progress', '${(progress * 100).toInt()}%'),
                _buildDetailItem('Tugas', '$completed/$total'),
                _buildDetailItem(
                  'Nilai Rata-rata',
                  '${(progress * 100).toInt()}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
