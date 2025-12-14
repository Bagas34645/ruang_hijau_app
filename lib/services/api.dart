import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const baseUrl = 'http://127.0.0.1:5000';

  // --- Auth ---
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    dynamic parsed;
    if (res.body.isNotEmpty) {
      parsed = jsonDecode(res.body);
    }

    // The Flask backend returns user info (no token). Store user id locally.
    dynamic user;
    if (parsed is Map && parsed['user'] != null) {
      user = parsed['user'];
      try {
        final prefs = await SharedPreferences.getInstance();
        if (user is Map && user['id'] != null) {
          await prefs.setInt('user_id', user['id']);
        }
        await prefs.setString('user', jsonEncode(user));
      } catch (_) {}
    }

    return {'statusCode': res.statusCode, 'body': parsed, 'user': user};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('user_id');
  }

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, String> _jsonHeaders([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- Posts ---
  static Future<Map<String, dynamic>> fetchPosts() async {
    final url = Uri.parse('$baseUrl/post/');
    final token = await _token();
    try {
      print('DEBUG fetchPosts: Requesting $url with token=$token');
      final res = await http
          .get(url, headers: _jsonHeaders(token))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG fetchPosts: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG fetchPosts: statusCode=${res.statusCode}');
      print('DEBUG fetchPosts: body=${res.body}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG fetchPosts ERROR: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createPost(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/post/add');
    final token = await _token();
    final res = await http.post(
      url,
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
  }

  static Future<Map<String, dynamic>> createPostMultipart(
    Map<String, dynamic> body, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final url = Uri.parse('$baseUrl/post/add');
    final token = await _token();
    if (imageBytes != null && filename != null) {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Accept': 'application/json'});
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields.addAll(body.map((k, v) => MapEntry(k, v.toString())));

      final mimeType = lookupMimeType(filename) ?? 'application/octet-stream';
      final parts = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    }
    return createPost(body);
  }

  // --- Events ---
  static Future<Map<String, dynamic>> fetchEvents() async {
    final url = Uri.parse('$baseUrl/events');
    final token = await _token();
    try {
      print('DEBUG fetchEvents: Requesting $url');
      final res = await http
          .get(url, headers: _jsonHeaders(token))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG fetchEvents: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG fetchEvents: statusCode=${res.statusCode}');
      print('DEBUG fetchEvents: body=${res.body}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG fetchEvents ERROR: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createEvent(
    Map<String, dynamic> body, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final url = Uri.parse('$baseUrl/events/add');
    final token = await _token();
    if (imageBytes != null && filename != null) {
      // multipart upload from bytes (works on web & mobile)
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Accept': 'application/json'});
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(body.map((k, v) => MapEntry(k, v.toString())));

      final mimeType = lookupMimeType(filename) ?? 'application/octet-stream';
      final parts = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    }

    final res = await http.post(
      url,
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
  }

  static Future<Map<String, dynamic>> updateEvent(
    int id,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/events/update/$id');
    final token = await _token();
    final res = await http.put(
      url,
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
  }

  static Future<Map<String, dynamic>> deleteEvent(int id) async {
    final url = Uri.parse('$baseUrl/events/delete/$id');
    final token = await _token();
    final res = await http.delete(url, headers: _jsonHeaders(token));
    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
  }

  // --- Comments ---
  static Future<Map<String, dynamic>> fetchComments(int postId) async {
    final url = Uri.parse('$baseUrl/comment/$postId');
    final token = await _token();
    try {
      print('DEBUG fetchComments: Requesting $url');
      final res = await http
          .get(url, headers: _jsonHeaders(token))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG fetchComments: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG fetchComments: statusCode=${res.statusCode}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG fetchComments ERROR: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addComment(
    int postId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/comment/add');
    final token = await _token();
    try {
      print('DEBUG addComment: Requesting $url with body=$body');
      final res = await http
          .post(url, headers: _jsonHeaders(token), body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG addComment: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG addComment: statusCode=${res.statusCode}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG addComment ERROR: $e');
      rethrow;
    }
  }
}
