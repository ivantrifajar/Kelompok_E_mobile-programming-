import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SiswaService {
  // Create new siswa with multiple classes support
  Future<Map<String, dynamic>> createSiswa({
    required String userId,
    required String nis,
    required List<String> kelasIds,
    required String jenisKelamin,
    required String tanggalLahir,
    String? alamat,
    String? noTelepon,
    String? namaOrangTua,
  }) async {
    try {
      final requestBody = {
        'user_id': userId,
        'nis': nis,
        'kelas_ids': kelasIds, // Now properly sending multiple classes
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': tanggalLahir,
        if (alamat != null) 'alamat': alamat,
        if (noTelepon != null) 'no_telepon': noTelepon,
        if (namaOrangTua != null) 'nama_orang_tua': namaOrangTua,
      };
      
      print('=== SiswaService DEBUG ===');
      print('Request URL: ${ApiConfig.siswa}');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('========================');
      
      final response = await http
          .post(
            Uri.parse(ApiConfig.siswa),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.timeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Siswa berhasil ditambahkan',
          'data': data['data'],
        };
      } else {
        print('API Error - Status: ${response.statusCode}');
        print('API Error - Message: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan siswa',
        };
      }
    } catch (e) {
      print('Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get all siswa
  Future<Map<String, dynamic>> getAllSiswa({
    String? kelasId,
    String? jenisKelamin,
    bool? isActive,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (kelasId != null) queryParams['kelas_id'] = kelasId;
      if (jenisKelamin != null) queryParams['jenis_kelamin'] = jenisKelamin;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final uri = Uri.parse(
        ApiConfig.siswa,
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'], 'count': data['count']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data siswa',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get siswa by kelas
  Future<Map<String, dynamic>> getSiswaByKelas(String kelasId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.siswa}/kelas/$kelasId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
          'kelas': data['kelas'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data siswa',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get siswa by ID
  Future<Map<String, dynamic>> getSiswaById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.siswa}/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Siswa tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update siswa
  Future<Map<String, dynamic>> updateSiswa({
    required String id,
    String? namaLengkap,
    String? nis,
    String? email,
    String? kelasId,
    String? jenisKelamin,
    String? tanggalLahir,
    String? alamat,
    String? noTelepon,
    String? namaOrangTua,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (namaLengkap != null) body['nama_lengkap'] = namaLengkap;
      if (nis != null) body['nis'] = nis;
      if (email != null) body['email'] = email;
      if (kelasId != null) body['kelas_id'] = kelasId;
      if (jenisKelamin != null) body['jenis_kelamin'] = jenisKelamin;
      if (tanggalLahir != null) body['tanggal_lahir'] = tanggalLahir;
      if (alamat != null) body['alamat'] = alamat;
      if (noTelepon != null) body['no_telepon'] = noTelepon;
      if (namaOrangTua != null) body['nama_orang_tua'] = namaOrangTua;
      if (isActive != null) body['isActive'] = isActive;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.siswa}/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Siswa berhasil diupdate',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate siswa',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Delete siswa
  Future<Map<String, dynamic>> deleteSiswa(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.siswa}/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Siswa berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus siswa',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Search siswa
  Future<Map<String, dynamic>> searchSiswa({
    required String query,
    String? kelasId,
  }) async {
    try {
      final queryParams = <String, String>{'q': query};
      if (kelasId != null) queryParams['kelas_id'] = kelasId;

      final uri = Uri.parse(
        '${ApiConfig.siswa}/search',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'], 'count': data['count']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mencari siswa',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get siswa by user ID (for student login)
  Future<Map<String, dynamic>> getSiswaByUserId(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.siswa}/user/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Data siswa tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
