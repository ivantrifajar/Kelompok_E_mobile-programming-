import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class FlashcardService {
  // Create new flashcard
  Future<Map<String, dynamic>> createFlashcard({
    required String judul,
    required String topik,
    required String deskripsi,
    required String kelasId,
    required String guruId,
    required List<Map<String, String>> kartu,
  }) async {
    try {
      final requestBody = {
        'judul': judul,
        'topik': topik,
        'deskripsi': deskripsi,
        'kelas_id': kelasId,
        'guru_id': guruId,
        'kartu': kartu,
      };

      print('Creating flashcard with data: ${jsonEncode(requestBody)}');
      print('Posting to: ${ApiConfig.flashcards}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.flashcards),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Flashcard berhasil dibuat',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat flashcard',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get all flashcards with optional filters
  Future<Map<String, dynamic>> getAllFlashcards({
    String? kelasId,
    String? guruId,
    bool? isActive,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (kelasId != null) queryParams['kelas_id'] = kelasId;
      if (guruId != null) queryParams['guru_id'] = guruId;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiConfig.flashcards).replace(
        queryParameters: queryParams,
      );

      print('Getting flashcards from: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);
      
      print('Flashcard API response status: ${response.statusCode}');
      print('Flashcard API response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data flashcard',
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

  // Get flashcard by ID
  Future<Map<String, dynamic>> getFlashcardById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.flashcards}/$id'),
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
          'message': data['message'] ?? 'Flashcard tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update flashcard
  Future<Map<String, dynamic>> updateFlashcard({
    required String id,
    required String judul,
    required String topik,
    required String deskripsi,
    required String kelasId,
    required List<Map<String, String>> kartu,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.flashcards}/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'judul': judul,
              'topik': topik,
              'deskripsi': deskripsi,
              'kelas_id': kelasId,
              'kartu': kartu,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Flashcard berhasil diupdate',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate flashcard',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Delete flashcard
  Future<Map<String, dynamic>> deleteFlashcard(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.flashcards}/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Flashcard berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus flashcard',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Toggle active status
  Future<Map<String, dynamic>> toggleActiveStatus(String id) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.flashcards}/$id/toggle-active'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Status berhasil diubah',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengubah status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get flashcards by class
  Future<Map<String, dynamic>> getFlashcardsByClass({
    required String kelasId,
    bool isActive = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'isActive': isActive.toString(),
      };

      final uri = Uri.parse('${ApiConfig.flashcards}/kelas/$kelasId').replace(
        queryParameters: queryParams,
      );

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
          'data': data['data'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data flashcard',
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

  // Search flashcards
  Future<Map<String, dynamic>> searchFlashcards({
    required String query,
    String? kelasId,
    String? guruId,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
      };

      if (kelasId != null) queryParams['kelas_id'] = kelasId;
      if (guruId != null) queryParams['guru_id'] = guruId;

      final uri = Uri.parse('${ApiConfig.flashcards}/search').replace(
        queryParameters: queryParams,
      );

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
          'data': data['data'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mencari flashcard',
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
}
