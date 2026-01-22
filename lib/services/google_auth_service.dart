import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Service untuk menangani Google Sign-In
class GoogleAuthService {
  /// Get base URL untuk API calls
  static String get baseUrl => AppConfig.baseUrl;

  /// Headers untuk JSON request
  static Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  /// Login atau register dengan Google
  ///
  /// Menggunakan data dari Google Sign-In Flutter package
  /// [googleId] - ID unik Google user
  /// [email] - Email user dari Google
  /// [displayName] - Nama tampilan user
  /// [photoUrl] - URL foto profil Google (opsional)
  /// [idToken] - Google ID token untuk verifikasi server-side (opsional tapi direkomendasikan)
  /// [accessToken] - Google access token (opsional)
  static Future<Map<String, dynamic>> signInWithGoogle({
    required String googleId,
    required String email,
    required String displayName,
    String? photoUrl,
    String? idToken,
    String? accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/google');

    Map<String, dynamic> body;

    // Prioritas: ID Token > Access Token > Direct Info
    if (idToken != null && idToken.isNotEmpty) {
      body = {'id_token': idToken};
    } else if (accessToken != null && accessToken.isNotEmpty) {
      body = {'access_token': accessToken};
    } else {
      // Fallback ke direct user info
      body = {
        'google_id': googleId,
        'email': email,
        'name': displayName,
        'profile_photo': photoUrl,
      };
    }

    print('DEBUG GoogleAuthService: Sending request to $url');
    print('DEBUG GoogleAuthService: Body keys: ${body.keys.toList()}');

    try {
      final response = await http
          .post(url, headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      print('DEBUG GoogleAuthService: Response status: ${response.statusCode}');

      dynamic parsed;
      if (response.body.isNotEmpty) {
        parsed = jsonDecode(response.body);
      }

      // Jika berhasil, simpan user data ke SharedPreferences
      if (response.statusCode == 200 &&
          parsed != null &&
          parsed['user'] != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final user = parsed['user'];

          if (user is Map && user['id'] != null) {
            await prefs.setInt('user_id', user['id']);
          }
          await prefs.setString('user', jsonEncode(user));
          await prefs.setBool('is_google_user', true);

          print('DEBUG GoogleAuthService: User saved to SharedPreferences');
        } catch (e) {
          print('DEBUG GoogleAuthService: Error saving user: $e');
        }
      }

      return {
        'statusCode': response.statusCode,
        'body': parsed,
        'user': parsed?['user'],
        'isNewUser': parsed?['is_new_user'] ?? false,
      };
    } catch (e) {
      print('DEBUG GoogleAuthService: Error: $e');
      return {'statusCode': 0, 'body': null, 'error': e.toString()};
    }
  }

  /// Verifikasi apakah user Google sudah terdaftar
  static Future<Map<String, dynamic>> verifyGoogleUser({
    String? googleId,
    String? email,
  }) async {
    if (googleId == null && email == null) {
      return {
        'statusCode': 400,
        'error': 'Either googleId or email is required',
      };
    }

    final url = Uri.parse('$baseUrl/api/auth/google/verify');
    final body = <String, dynamic>{};

    if (googleId != null) {
      body['google_id'] = googleId;
    }
    if (email != null) {
      body['email'] = email;
    }

    try {
      final response = await http
          .post(url, headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      dynamic parsed;
      if (response.body.isNotEmpty) {
        parsed = jsonDecode(response.body);
      }

      return {
        'statusCode': response.statusCode,
        'body': parsed,
        'exists': parsed?['exists'] ?? false,
        'user': parsed?['user'],
      };
    } catch (e) {
      print('DEBUG GoogleAuthService: Verify error: $e');
      return {'statusCode': 0, 'body': null, 'error': e.toString()};
    }
  }

  /// Check apakah current user adalah Google user
  static Future<bool> isGoogleUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_google_user') ?? false;
  }

  /// Logout - clear semua data user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user');
    await prefs.remove('is_google_user');
    await prefs.remove('token');
  }

  /// Get stored user data
  static Future<Map<String, dynamic>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null && userString.isNotEmpty) {
      try {
        return jsonDecode(userString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
