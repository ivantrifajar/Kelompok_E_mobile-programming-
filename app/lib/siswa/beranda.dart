import 'package:flutter/material.dart';
import 'kelas/kelas-saya.dart';
import 'tabbar/profile.dart';
import 'tabbar/flashcard.dart';
import '../services/siswa_service.dart';
import '../services/user_service.dart';
import '../services/flashcard_service.dart';

class BerandaSiswa extends StatefulWidget {
  const BerandaSiswa({super.key});

  @override
  State<BerandaSiswa> createState() => _BerandaSiswaState();
}

class _BerandaSiswaState extends State<BerandaSiswa> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SiswaService _siswaService = SiswaService();
  final UserService _userService = UserService();
  final FlashcardService _flashcardService = FlashcardService();
  
  List<Map<String, dynamic>> _kelasList = [];
  List<Map<String, dynamic>> _flashcardList = [];
  List<Map<String, dynamic>> _recentActivities = [];
  String? _namaLengkap;
  bool _isLoading = true;
  int _totalKelas = 0;
  int _totalFlashcard = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSiswaData();
  }

  Future<void> _loadSiswaData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      final userId = await _userService.getUserId();
      
      if (userId != null) {
        // Get siswa data by user ID
        final result = await _siswaService.getSiswaByUserId(userId);
        
        print('=== SISWA BERANDA DEBUG ===');
        print('API Result: $result');
        print('========================');
        
        if (result['success'] == true && mounted) {
          final siswaData = result['data'] as Map<String, dynamic>? ?? {};
          final userData = siswaData['user_id'] as Map<String, dynamic>? ?? {};
          
          // Handle both old format (kelas_id) and new format (kelas_ids)
          List<Map<String, dynamic>> kelasList = [];
          
          if (siswaData['kelas_ids'] != null) {
            // New format: multiple classes
            final kelasIds = siswaData['kelas_ids'] as List? ?? [];
            kelasList = kelasIds.map((kelas) {
              if (kelas is Map<String, dynamic>) {
                return kelas;
              }
              return <String, dynamic>{};
            }).toList();
          } else if (siswaData['kelas_id'] != null) {
            // Old format: single class (for backward compatibility)
            final kelasData = siswaData['kelas_id'] as Map<String, dynamic>? ?? {};
            if (kelasData.isNotEmpty) {
              kelasList = [kelasData];
            }
          }
          
          print('Parsed kelas list: $kelasList');
          print('Total kelas: ${kelasList.length}');
          
          // Load flashcards for all student's classes
          await _loadFlashcards(kelasList);
          
          setState(() {
            _kelasList = kelasList;
            _totalKelas = kelasList.length;
            _namaLengkap = userData['nama_lengkap']?.toString() ?? 'Siswa';
            _isLoading = false;
          });
        } else {
          // User belum terdaftar sebagai siswa
          setState(() {
            _namaLengkap = 'Siswa';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFlashcards(List<Map<String, dynamic>> kelasList) async {
    try {
      List<Map<String, dynamic>> allFlashcards = [];
      
      // Get flashcards for each class
      for (final kelas in kelasList) {
        final kelasId = kelas['_id']?.toString();
        if (kelasId != null) {
          final result = await _flashcardService.getFlashcardsByClass(
            kelasId: kelasId,
            isActive: true,
          );
          
          if (result['success'] == true) {
            final flashcards = result['data'] as List? ?? [];
            allFlashcards.addAll(flashcards.map((fc) => fc as Map<String, dynamic>));
          }
        }
      }
      
      // Remove duplicates based on flashcard ID
      final uniqueFlashcards = <String, Map<String, dynamic>>{};
      for (final flashcard in allFlashcards) {
        final id = flashcard['_id']?.toString();
        if (id != null) {
          uniqueFlashcards[id] = flashcard;
        }
      }
      
      setState(() {
        _flashcardList = uniqueFlashcards.values.toList();
        _totalFlashcard = _flashcardList.length;
      });
      
      // Generate recent activities from flashcards and classes
      _generateRecentActivities();
      
      print('Loaded ${_flashcardList.length} flashcards for student');
    } catch (e) {
      print('Error loading flashcards: $e');
    }
  }

  void _generateRecentActivities() {
    List<Map<String, dynamic>> activities = [];
    
    // Add flashcard activities (latest 3)
    for (final flashcard in _flashcardList.take(3)) {
      final judul = flashcard['judul']?.toString() ?? 'Flashcard';
      final createdAt = flashcard['createdAt']?.toString() ?? '';
      
      activities.add({
        'type': 'flashcard',
        'title': 'Flashcard "$judul" tersedia',
        'subtitle': _formatTimeAgo(createdAt),
        'icon': Icons.style,
        'color': Colors.blue,
      });
    }
    
    // Add class activities (latest 2)
    for (final kelas in _kelasList.take(2)) {
      final namaKelas = kelas['nama']?.toString() ?? 'Kelas';
      final tahunAjaran = kelas['tahun_ajaran']?.toString() ?? '';
      final createdAt = kelas['createdAt']?.toString() ?? '';
      
      activities.add({
        'type': 'kelas',
        'title': 'Bergabung dengan kelas $namaKelas ${tahunAjaran.isNotEmpty ? '($tahunAjaran)' : ''}',
        'subtitle': _formatTimeAgo(createdAt),
        'icon': Icons.school,
        'color': Colors.green,
      });
    }
    
    // Sort by most recent (for demo, we'll keep current order)
    // In real implementation, you'd sort by actual timestamps
    
    setState(() {
      _recentActivities = activities.take(5).toList();
    });
  }

  String _formatTimeAgo(String dateString) {
    if (dateString.isEmpty) return 'Baru saja';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          'Dashboard Siswa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBerandaTab(),
          FlashcardTab(
            flashcardList: _flashcardList,
            isLoading: _isLoading,
          ),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _tabController.index,
          onTap: (index) {
            setState(() {
              _tabController.animateTo(index);
            });
          },
          selectedItemColor: const Color(0xFF1976D2),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style),
              label: 'Flashcard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Tab 1: Beranda
  Widget _buildBerandaTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1976D2),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _namaLengkap ?? 'Siswa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.class_,
                          title: 'Kelas',
                          value: _isLoading ? '-' : _totalKelas.toString(),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.style,
                          title: 'Flashcard',
                          value: _isLoading ? '-' : _totalFlashcard.toString(),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Main Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu Utama',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 20),
                // Kelas Saya Button
                _buildMainActionButton(
                  icon: Icons.school,
                  title: 'Kelas Saya',
                  subtitle: _kelasList.isNotEmpty 
                      ? _totalKelas == 1 
                          ? 'Kelas ${_kelasList.first['nama']} - ${_kelasList.first['tahun_ajaran']}'
                          : 'Terdaftar di $_totalKelas kelas'
                      : 'Anda belum terdaftar di kelas manapun',
                  color: const Color(0xFF1976D2),
                  onTap: () {
                    if (_kelasList.isNotEmpty) {
                      // Navigate to Kelas Saya page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KelasSayaPage(),
                        ),
                      );
                    } else {
                      // Show message that user is not enrolled in any class
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Anda belum terdaftar di kelas manapun. Hubungi guru untuk mendaftarkan Anda.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Flashcard Button
                _buildMainActionButton(
                  icon: Icons.style,
                  title: 'Flashcard',
                  subtitle: _isLoading 
                      ? 'Memuat flashcard...'
                      : _totalFlashcard > 0 
                          ? '$_totalFlashcard flashcard tersedia'
                          : 'Belum ada flashcard tersedia',
                  color: const Color(0xFF64B5F6),
                  onTap: () {
                    // Navigate to Flashcard tab
                    setState(() {
                      _tabController.animateTo(1);
                    });
                  },
                ),
                const SizedBox(height: 30),
                // Recent Activity
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 15),
                ..._recentActivities.map((activity) => _buildActivityCard(
                  icon: activity['icon'] as IconData,
                  title: activity['title'] as String,
                  time: activity['subtitle'] as String,
                  color: activity['color'] as Color,
                )).toList(),
                if (_recentActivities.isEmpty && !_isLoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada aktivitas terbaru',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isLoading)
                  ...List.generate(3, (index) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 12,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Helper Widgets
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
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
                    fontSize: value.length > 3 ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard({
    required String title,
    required String teacher,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.book, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      teacher,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Progress: ${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMainActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 35),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }


}