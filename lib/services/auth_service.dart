import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  // Melakukan request login.
  // Menyimpan token dan data pengguna ke SharedPreferences jika sukses.
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await ApiService.post('/login', {
        'username': username,
        'password': password,
      });
      final json = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(json);
      if (loginResponse.status == 'success' &&
          loginResponse.token != null &&
          loginResponse.user != null) {
        await saveSession(loginResponse.token!, loginResponse.user!);
      }
      return loginResponse;
    } catch (e) {
      return LoginResponse(
        status: 'error',
        message: 'Gagal menghubungkan ke server: ${e.toString()}',
      );
    }
  }

  // Menyimpan sesi aktif ke SharedPreferences.
  Future<void> saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  // Memeriksa apakah sesi pengguna saat ini sedang aktif (sudah login).
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  // Mengambil data detail pengguna yang disimpan di sesi lokal.
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  // Mengambil token autentikasi yang disimpan di sesi lokal.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Menghapus variabel sesi aktif (proses logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // Register
  Future<Map<String, dynamic>> register({
  required String name,
  required String username,
  required String email,
  required String password,
}) async {
  try {
    final response = await ApiService.post(
      '/register',
      {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.body.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Server tidak memberikan respons.',
      };
    }

    final dynamic data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return {
        'success': true,
        'message':
            data['message'] ?? 'Pendaftaran berhasil',
      };
    }

    return {
      'success': false,
      'message':
          data['message'] ?? 'Pendaftaran gagal',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Gagal menghubungkan ke server: $e',
    };
  }
}
}
