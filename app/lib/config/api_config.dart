class ApiConfig {
  // Base URL untuk API
  // Ganti dengan IP address komputer Anda jika testing di device fisik
  // Untuk emulator Android gunakan 10.0.2.2
  // Untuk iOS simulator gunakan localhost
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Endpoints
  static const String register = '$baseUrl/users/register';
  static const String login = '$baseUrl/users/login';
  static const String users = '$baseUrl/users';
  static const String kelas = '$baseUrl/kelas';
  static const String siswa = '$baseUrl/siswa';
  static const String flashcards = '$baseUrl/flashcards';
  static const String searchSiswaUsers = '$baseUrl/users/search-siswa';

  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}
