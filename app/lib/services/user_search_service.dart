import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserSearchService {
  // Search available siswa users (not yet assigned to any class)
  Future<Map<String, dynamic>> searchAvailableSiswa({
    required String query,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
      };

      final uri = Uri.parse(ApiConfig.searchSiswaUsers)
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
}
