import 'package:flutter/material.dart';
import 'tabbar/progress-siswa.dart';
import 'tabbar/profile.dart';
import 'kelola-kelas/kelola-kelas.dart';
import 'kelola-flashcard/kelola-flashcard.dart';
import '../services/user_service.dart';
import '../services/kelas_service.dart';
import '../services/siswa_service.dart';
import '../services/flashcard_service.dart';

class BerandaGuru extends StatefulWidget {
  const BerandaGuru({super.key});

  @override
  State<BerandaGuru> createState() => _BerandaGuruState();
}

class _BerandaGuruState extends State<BerandaGuru> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final KelasService _kelasService = KelasService();
  final SiswaService _siswaService = SiswaService();
  final FlashcardService _flashcardService = FlashcardService();
  
  String _userName = 'Guru';
  int _totalKelas = 0;
  int _totalSiswa = 0;
  int _totalFlashcard = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentActivities = [];
  
  // TODO: Get actual guru_id from user session/auth
  final String _guruId = '68e630667aa27040bcb95fed';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data
      final userData = await _userService.getUserData();
      final userId = userData['userId'];
      
      if (userId != null) {
        // Load kelas data
        final kelasResult = await _kelasService.getAllKelas(guruId: userId);
        
        if (kelasResult['success'] == true) {
          final kelasList = kelasResult['data'] as List? ?? [];
          
          // Count unique siswa (avoid counting same student multiple times)
          Set<String> uniqueSiswaIds = {};
          
          for (final kelas in kelasList) {
            final kelasMap = kelas as Map<String, dynamic>? ?? {};
            final kelasId = kelasMap['_id']?.toString();
            
            if (kelasId != null) {
              final siswaResult = await _siswaService.getSiswaByKelas(kelasId);
              if (siswaResult['success'] == true) {
                final siswaList = siswaResult['data'] as List? ?? [];
                
                // Add each unique student ID to the set
                for (final siswa in siswaList) {
                  final siswaMap = siswa as Map<String, dynamic>? ?? {};
                  final userId = siswaMap['user_id']?['_id']?.toString();
                  if (userId != null) {
                    uniqueSiswaIds.add(userId);
                  }
                }
              }
            }
          }
          
          final totalSiswa = uniqueSiswaIds.length;
          
          // Load flashcard data
          print('Loading flashcards for guru: $_guruId');
          final flashcardResult = await _flashcardService.getAllFlashcards(
            guruId: _guruId,
            limit: 100, // Get more data for accurate count
          );
          
          print('Flashcard result: $flashcardResult');
          
          int totalFlashcard = 0;
          List<Map<String, dynamic>> recentActivities = [];
          
          if (flashcardResult['success'] == true) {
            final flashcardList = flashcardResult['data'] as List? ?? [];
            totalFlashcard = flashcardList.length;
            print('Found $totalFlashcard flashcards');
            
            // Create recent activities from flashcards
            for (final flashcard in flashcardList.take(5)) { // Take latest 5
              final flashcardMap = flashcard as Map<String, dynamic>? ?? {};
              final createdAt = flashcardMap['createdAt']?.toString() ?? '';
              final judul = flashcardMap['judul']?.toString() ?? 'Flashcard';
              
              recentActivities.add({
                'type': 'flashcard',
                'title': 'Flashcard "$judul" dibuat',
                'subtitle': _formatTimeAgo(createdAt),
                'icon': Icons.style,
                'color': Colors.blue,
              });
            }
          } else {
            print('Flashcard API failed: ${flashcardResult['message']}');
          }
          
          // Add kelas activities
          for (final kelas in kelasList.take(3)) { // Take latest 3 classes
            final kelasMap = kelas as Map<String, dynamic>? ?? {};
            final createdAt = kelasMap['createdAt']?.toString() ?? '';
            final namaKelas = kelasMap['nama']?.toString() ?? 'Kelas';
            
            recentActivities.add({
              'type': 'kelas',
              'title': 'Kelas "$namaKelas" dibuat',
              'subtitle': _formatTimeAgo(createdAt),
              'icon': Icons.class_,
              'color': Colors.green,
            });
          }
          
          // Sort activities by time (newest first)
          recentActivities.sort((a, b) {
            // For demo purposes, we'll keep the current order
            // In real implementation, you'd parse the timestamps and sort
            return 0;
          });
          
          print('Total activities generated: ${recentActivities.length}');
          print('Activities: $recentActivities');
          
          if (mounted) {
            setState(() {
              _userName = userData['userName'] ?? 'Guru';
              _totalKelas = kelasList.length;
              _totalSiswa = totalSiswa;
              _totalFlashcard = totalFlashcard;
              _recentActivities = recentActivities.take(5).toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _userName = userData['userName'] ?? 'Guru';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _userName = 'Guru';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _userName = 'Guru';
          _isLoading = false;
        });
      }
    }
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
          'Dashboard Guru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserData,
          ),
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
          const ProgressSiswaPage(),
          const ProfilePage(),
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
              icon: Icon(Icons.trending_up),
              label: 'Progress Siswa',
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
                    _userName,
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
                          value: _isLoading ? '-' : '$_totalKelas',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          title: 'Siswa',
                          value: _isLoading ? '-' : '$_totalSiswa',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.style,
                          title: 'Flashcard',
                          value: _isLoading ? '-' : '$_totalFlashcard',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Main Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu Utama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 15),
                // Kelola Kelas Button
                _buildMainActionButton(
                  icon: Icons.class_,
                  title: 'Kelola Kelas',
                  subtitle: 'Atur dan kelola kelas Anda',
                  color: const Color(0xFF1976D2),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KelolaKelasPage(),
                      ),
                    );
                    // Refresh data when returning from kelola kelas
                    _loadUserData();
                  },
                ),
                const SizedBox(height: 15),
                // Kelola Flashcard Button
                _buildMainActionButton(
                  icon: Icons.style,
                  title: 'Kelola Flashcard',
                  subtitle: 'Atur dan kelola flashcard pembelajaran',
                  color: const Color(0xFF64B5F6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KelolaFlashcardPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
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

}
