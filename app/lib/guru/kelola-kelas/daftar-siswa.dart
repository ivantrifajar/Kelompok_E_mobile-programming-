import 'package:flutter/material.dart';
import '../../services/siswa_service.dart';
import 'tambah-siswa.dart';

class DaftarSiswaPage extends StatefulWidget {
  final String kelasId;
  final String namaKelas;

  const DaftarSiswaPage({
    super.key,
    required this.kelasId,
    required this.namaKelas,
  });

  @override
  State<DaftarSiswaPage> createState() => _DaftarSiswaPageState();
}

class _DaftarSiswaPageState extends State<DaftarSiswaPage> {
  final SiswaService _siswaService = SiswaService();
  List<Map<String, dynamic>> _siswaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSiswa();
  }

  Future<void> _loadSiswa() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _siswaService.getSiswaByKelas(widget.kelasId);
      
      if (result['success'] == true && mounted) {
        setState(() {
          final dataList = result['data'] as List? ?? [];
          _siswaList = dataList.map<Map<String, dynamic>>((siswa) {
            final siswaMap = siswa as Map<String, dynamic>? ?? {};
            final userMap = siswaMap['user_id'] as Map<String, dynamic>? ?? {};
            return {
              'id': siswaMap['_id']?.toString() ?? '',
              'user_id': userMap['_id']?.toString() ?? '',
              'nama_lengkap': userMap['nama_lengkap']?.toString() ?? 'Nama Siswa',
              'email': userMap['email']?.toString() ?? '',
              'nis': siswaMap['nis']?.toString() ?? '',
              'jenis_kelamin': siswaMap['jenis_kelamin']?.toString() ?? 'L',
              'tanggal_lahir': siswaMap['tanggal_lahir']?.toString(),
              'alamat': siswaMap['alamat']?.toString(),
              'no_telepon': siswaMap['no_telepon']?.toString(),
              'nama_orang_tua': siswaMap['nama_orang_tua']?.toString(),
              'createdAt': siswaMap['createdAt']?.toString(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']?.toString() ?? 'Gagal memuat data siswa'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Siswa ${widget.namaKelas}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSiswa,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFF64B5F6),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Stats Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, color: Colors.white, size: 30),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text(
                              '${_siswaList.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Total Siswa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button Tambah Siswa
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TambahSiswaPage(
                              kelasId: widget.kelasId,
                              namaKelas: widget.namaKelas,
                            ),
                          ),
                        );

                        if (result != null) {
                          _loadSiswa(); // Reload data
                        }
                      },
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text(
                        'Tambah Siswa Baru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Daftar Siswa
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  )
                : _siswaList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada siswa',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah siswa baru untuk memulai',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSiswa,
                        color: const Color(0xFF1976D2),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _siswaList.length,
                          itemBuilder: (context, index) {
                            final siswa = _siswaList[index];
                            return _buildSiswaCard(siswa, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(Map<String, dynamic> siswa, int index) {
    final nama = siswa['nama_lengkap'] ?? 'Nama Siswa';
    final nis = siswa['nis'] ?? '';
    final email = siswa['email'] ?? '';
    final jenisKelamin = siswa['jenis_kelamin'] ?? 'L';
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    final color = colors[index % colors.length];

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
          onTap: () => _showDetailSiswaDialog(siswa),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    jenisKelamin == 'L' ? Icons.boy : Icons.girl,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 15),
                // Info Siswa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIS: $nis',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gender Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jenisKelamin == 'L' ? 'L' : 'P',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailSiswaDialog(Map<String, dynamic> siswa) {
    final tanggalLahir = siswa['tanggal_lahir'] != null 
        ? DateTime.tryParse(siswa['tanggal_lahir'].toString())?.toLocal()
        : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(siswa['nama_lengkap']?.toString() ?? 'Detail Siswa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('NIS', siswa['nis']?.toString() ?? '-'),
              _buildDetailRow('Email', siswa['email']?.toString() ?? '-'),
              _buildDetailRow('Jenis Kelamin', siswa['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan'),
              if (tanggalLahir != null)
                _buildDetailRow('Tanggal Lahir', '${tanggalLahir.day}/${tanggalLahir.month}/${tanggalLahir.year}'),
              if (siswa['alamat'] != null && siswa['alamat'].toString().isNotEmpty)
                _buildDetailRow('Alamat', siswa['alamat'].toString()),
              if (siswa['no_telepon'] != null && siswa['no_telepon'].toString().isNotEmpty)
                _buildDetailRow('No. Telepon', siswa['no_telepon'].toString()),
              if (siswa['nama_orang_tua'] != null && siswa['nama_orang_tua'].toString().isNotEmpty)
                _buildDetailRow('Nama Orang Tua', siswa['nama_orang_tua'].toString()),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
