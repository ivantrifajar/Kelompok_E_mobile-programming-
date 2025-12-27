import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MateriService {
  // Create new materi
  Future<Map<String, dynamic>> createMateri({
    required String judul,
    required String konten,
    required String kelasId,
    required String guruId,
    String? deskripsi,
    String? tipeMateri,
    String? fileUrl,
    int? urutan,
    List<String>? tags,
  }) async {
    try {
      final requestBody = {
        'judul': judul,
        'konten': konten,
        'kelas_id': kelasId,
        'guru_id': guruId,
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (tipeMateri != null) 'tipe_materi': tipeMateri,
        if (fileUrl != null) 'file_url': fileUrl,
        if (urutan != null) 'urutan': urutan,
        if (tags != null) 'tags': tags,
      };

      print('=== MateriService CREATE DEBUG ===');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/materi'),
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
          'message': data['message'] ?? 'Materi berhasil dibuat',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat materi',
        };
      }
    } catch (e) {
      print('MateriService CREATE Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get materi by kelas
  Future<Map<String, dynamic>> getMateriByKelas(
    String kelasId, {
    int page = 1,
    int limit = 10,
    String sortBy = 'urutan',
    String sortOrder = 'asc',
    String search = '',
    String? tipeMateri,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (search.isNotEmpty) 'search': search,
        if (tipeMateri != null) 'tipe_materi': tipeMateri,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/materi/kelas/$kelasId')
          .replace(queryParameters: queryParams);

      print('=== MateriService GET BY KELAS DEBUG ===');
      print('Request URL: $uri');

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConfig.timeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'pagination': data['pagination'] ?? {},
          'statistics': data['statistics'] ?? {},
          'kelas': data['kelas'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat materi',
          'data': [],
        };
      }
    } catch (e) {
      print('MateriService GET BY KELAS Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Get materi by ID
  Future<Map<String, dynamic>> getMateriById(String materiId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/materi/$materiId'),
            headers: {'Content-Type': 'application/json'},
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
          'message': data['message'] ?? 'Materi tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update materi
  Future<Map<String, dynamic>> updateMateri({
    required String materiId,
    required String guruId,
    String? judul,
    String? deskripsi,
    String? konten,
    String? tipeMateri,
    String? fileUrl,
    int? urutan,
    List<String>? tags,
    bool? isActive,
  }) async {
    try {
      final requestBody = {
        'guru_id': guruId,
        if (judul != null) 'judul': judul,
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (konten != null) 'konten': konten,
        if (tipeMateri != null) 'tipe_materi': tipeMateri,
        if (fileUrl != null) 'file_url': fileUrl,
        if (urutan != null) 'urutan': urutan,
        if (tags != null) 'tags': tags,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/materi/$materiId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Materi berhasil diupdate',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate materi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Delete materi
  Future<Map<String, dynamic>> deleteMateri({
    required String materiId,
    required String guruId,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/materi/$materiId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'guru_id': guruId}),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Materi berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus materi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Search materi
  Future<Map<String, dynamic>> searchMateri({
    required String query,
    String? kelasId,
    String? tipeMateri,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        if (kelasId != null) 'kelas_id': kelasId,
        if (tipeMateri != null) 'tipe_materi': tipeMateri,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/materi/search')
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'pagination': data['pagination'] ?? {},
          'query': data['query'] ?? query,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mencari materi',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Reorder materi
  Future<Map<String, dynamic>> reorderMateri({
    required String kelasId,
    required String guruId,
    required List<Map<String, String>> materiOrders,
  }) async {
    try {
      final requestBody = {
        'kelas_id': kelasId,
        'guru_id': guruId,
        'materi_orders': materiOrders,
      };

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/materi/reorder'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Urutan materi berhasil diupdate',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate urutan materi',
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
