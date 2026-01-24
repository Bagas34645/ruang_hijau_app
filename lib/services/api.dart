import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class Api {
  /// Get base URL untuk API calls
  /// Automatically selects correct URL based on platform
  static String get baseUrl => AppConfig.baseUrl;

  // --- Auth ---
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final res = await http.post(
      url,
      headers: _jsonHeaders(),
      body: jsonEncode(body),
    );

    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      url,
      headers: _jsonHeaders(),
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
    // Add ngrok-skip-browser-warning header to bypass ngrok browser warning
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- Posts ---
  static Future<Map<String, dynamic>> fetchPosts() async {
    final url = Uri.parse('$baseUrl/api/posts/');
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
    final url = Uri.parse('$baseUrl/api/posts/add');
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
    final url = Uri.parse('$baseUrl/api/posts/add');
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

  static Future<Map<String, dynamic>> updatePost(
    int postId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/posts/$postId');
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

  static Future<Map<String, dynamic>> updatePostMultipart(
    int postId,
    Map<String, dynamic> body, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final url = Uri.parse('$baseUrl/api/posts/$postId');
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
    return updatePost(postId, body);
  }

  static Future<Map<String, dynamic>> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/api/posts/$postId');
    final token = await _token();
    final res = await http.delete(url, headers: _jsonHeaders(token));
    return {
      'statusCode': res.statusCode,
      'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
    };
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

  // --- Campaigns ---
  static Future<Map<String, dynamic>> fetchCampaigns({
    int limit = 20,
    int page = 1,
    String? category,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/campaigns/?limit=$limit&page=$page${category != null ? '&category=$category' : ''}',
    );
    final token = await _token();
    try {
      print('DEBUG fetchCampaigns: Requesting $url');
      final res = await http
          .get(url, headers: _jsonHeaders(token))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG fetchCampaigns: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG fetchCampaigns: statusCode=${res.statusCode}');
      print('DEBUG fetchCampaigns: body=${res.body}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG fetchCampaigns ERROR: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCampaignDetail(int campaignId) async {
    final url = Uri.parse('$baseUrl/api/campaigns/$campaignId');
    final token = await _token();
    try {
      print('DEBUG getCampaignDetail: Requesting $url');
      final res = await http
          .get(url, headers: _jsonHeaders(token))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print(
                'DEBUG getCampaignDetail: Request TIMEOUT after 10 seconds',
              );
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG getCampaignDetail: statusCode=${res.statusCode}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG getCampaignDetail ERROR: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createCampaignMultipart(
    Map<String, dynamic> body, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final url = Uri.parse('$baseUrl/api/campaigns/');
    final token = await _token();

    print(
      'DEBUG createCampaignMultipart: imageBytes=$imageBytes, filename=$filename',
    );

    if (imageBytes != null && filename != null) {
      // Multipart upload from bytes (works on web & mobile)
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Accept': 'application/json'});
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add form fields
      request.fields.addAll(body.map((k, v) => MapEntry(k, v.toString())));

      // Add image file
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

      print('DEBUG createCampaignMultipart: Sending multipart request');
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      print('DEBUG createCampaignMultipart: statusCode=${res.statusCode}');
      print('DEBUG createCampaignMultipart: body=${res.body}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    }

    // Fallback: JSON request without image
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

  // Update campaign (with image)
  static Future<Map<String, dynamic>> updateCampaignMultipart(
    int campaignId,
    Map<String, dynamic> body, {
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final url = Uri.parse('$baseUrl/api/campaigns/$campaignId');
    final token = await _token();

    print(
      'DEBUG updateCampaignMultipart: imageBytes=$imageBytes, filename=$filename',
    );

    try {
      // If image provided, use multipart
      if (imageBytes != null && filename != null && imageBytes.isNotEmpty) {
        final request = http.MultipartRequest('PUT', url)
          ..headers.addAll(_jsonHeaders(token));

        // Add form fields
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Detect MIME type
        final mimeType = lookupMimeType(filename) ?? 'image/jpeg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
            contentType: MediaType.parse(mimeType),
          ),
        );

        print('DEBUG updateCampaignMultipart: Sending multipart request');
        final res = await request.send();
        final resBody = await res.stream.bytesToString();
        print('DEBUG updateCampaignMultipart: statusCode=${res.statusCode}');
        print('DEBUG updateCampaignMultipart: body=$resBody');
        return {
          'statusCode': res.statusCode,
          'body': resBody.isNotEmpty ? jsonDecode(resBody) : null,
        };
      }

      // Fallback: JSON request without image
      final res = await http.put(
        url,
        headers: _jsonHeaders(token),
        body: jsonEncode(body),
      );
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG updateCampaignMultipart ERROR: $e');
      rethrow;
    }
  }

  // Delete campaign
  static Future<Map<String, dynamic>> deleteCampaign(int campaignId) async {
    final url = Uri.parse('$baseUrl/api/campaigns/$campaignId');
    final token = await _token();

    try {
      print('DEBUG deleteCampaign: Requesting $url');
      final res = await http
          .delete(url, headers: _jsonHeaders(token))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG deleteCampaign: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );
      print('DEBUG deleteCampaign: statusCode=${res.statusCode}');
      print('DEBUG deleteCampaign: body=${res.body}');
      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG deleteCampaign ERROR: $e');
      rethrow;
    }
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

  // --- Feedback ---
  static Future<Map<String, dynamic>> submitFeedback({
    required String category,
    required int rating,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/api/feedback');
    final token = await _token();

    try {
      print('DEBUG submitFeedback: Requesting $url');
      print('DEBUG submitFeedback: category=$category, rating=$rating');

      final body = {'category': category, 'rating': rating, 'message': message};

      final res = await http
          .post(url, headers: _jsonHeaders(token), body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('DEBUG submitFeedback: Request TIMEOUT after 10 seconds');
              throw TimeoutException('Request timeout');
            },
          );

      print('DEBUG submitFeedback: statusCode=${res.statusCode}');
      print('DEBUG submitFeedback: body=${res.body}');

      return {
        'statusCode': res.statusCode,
        'body': res.body.isNotEmpty ? jsonDecode(res.body) : null,
      };
    } catch (e) {
      print('DEBUG submitFeedback ERROR: $e');
      rethrow;
    }
  }
}
