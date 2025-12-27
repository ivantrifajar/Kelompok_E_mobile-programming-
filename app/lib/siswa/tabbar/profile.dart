import 'package:flutter/material.dart';
import '../../services/siswa_service.dart';
import '../../services/user_service.dart';
import '../../auth/login.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final SiswaService _siswaService = SiswaService();
  final UserService _userService = UserService();
  
  Map<String, dynamic>? _siswaData;
  Map<String, dynamic>? _kelasData;
  String? _namaLengkap;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        
        if (result['success'] == true && mounted) {
          final siswaData = result['data'] as Map<String, dynamic>? ?? {};
          final userData = siswaData['user_id'] as Map<String, dynamic>? ?? {};
          final kelasData = siswaData['kelas_id'] as Map<String, dynamic>? ?? {};
          
          setState(() {
            _siswaData = siswaData;
            _kelasData = kelasData;
            _namaLengkap = userData['nama_lengkap']?.toString() ?? 'Siswa';
            _email = userData['email']?.toString() ?? '';
            _isLoading = false;
          });
        } else {
          // User belum terdaftar sebagai siswa
          setState(() {
            _namaLengkap = 'Siswa';
            _email = '';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1976D2),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _namaLengkap ?? 'Siswa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _email ?? 'email@example.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Student Info (if enrolled)
          if (_siswaData != null) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Siswa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.badge, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('NIS: ${_siswaData!['nis'] ?? '-'}'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('Kelas: ${_kelasData?['nama'] ?? '-'}'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('Tahun Ajaran: ${_kelasData?['tahun_ajaran'] ?? '-'}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          // Profile Menu
          _buildProfileMenuItem(Icons.edit, 'Edit Profile'),
          _buildProfileMenuItem(Icons.settings, 'Pengaturan'),
          _buildProfileMenuItem(Icons.help, 'Bantuan'),
          _buildProfileMenuItem(Icons.logout, 'Keluar'),
        ],
      ),
    );
  }

  void _handleMenuTap(String title) {
    switch (title) {
      case 'Keluar':
        _showLogoutDialog();
        break;
      case 'Edit Profile':
        // TODO: Navigate to edit profile page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur Edit Profile akan segera hadir'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'Pengaturan':
        // TODO: Navigate to settings page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur Pengaturan akan segera hadir'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'Bantuan':
        // TODO: Navigate to help page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur Bantuan akan segera hadir'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      default:
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Keluar'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear user session
                await _userService.clearUserData();
                
                if (mounted) {
                  // Navigate to login page and clear all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _handleMenuTap(title);
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1976D2)),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}