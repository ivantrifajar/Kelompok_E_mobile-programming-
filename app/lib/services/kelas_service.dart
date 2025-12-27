import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class KelasService {
  // Create new kelas
  Future<Map<String, dynamic>> createKelas({
    required String nama,
    required String guruId,
    String? tahunAjaran,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.kelas),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'nama': nama,
              'guru_id': guruId,
              if (tahunAjaran != null) 'tahun_ajaran': tahunAjaran,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kelas berhasil ditambahkan',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan kelas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get all kelas
  Future<Map<String, dynamic>> getAllKelas({
    String? guruId,
    String? tahunAjaran,
    bool? isActive,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (guruId != null) queryParams['guru_id'] = guruId;
      if (tahunAjaran != null) queryParams['tahun_ajaran'] = tahunAjaran;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final uri = Uri.parse(ApiConfig.kelas).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data kelas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get kelas by ID
  Future<Map<String, dynamic>> getKelasById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.kelas}/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kelas tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update kelas
  Future<Map<String, dynamic>> updateKelas({
    required String id,
    String? nama,
    String? tahunAjaran,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nama != null) body['nama'] = nama;
      if (tahunAjaran != null) body['tahun_ajaran'] = tahunAjaran;
      if (isActive != null) body['isActive'] = isActive;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.kelas}/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kelas berhasil diupdate',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate kelas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Delete kelas
  Future<Map<String, dynamic>> deleteKelas(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.kelas}/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kelas berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus kelas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Search kelas
  Future<Map<String, dynamic>> searchKelas({
    required String query,
    String? guruId,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
      };
      if (guruId != null) queryParams['guru_id'] = guruId;

      final uri = Uri.parse('${ApiConfig.kelas}/search')
          .replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mencari kelas',
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
