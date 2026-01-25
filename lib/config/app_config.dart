import 'package:flutter/foundation.dart';
import 'dart:io';

/// Konfigurasi aplikasi untuk berbagai platform
class AppConfig {
  // ============================================
  // BASE URL CONFIGURATION
  // ============================================

  /// URL backend yang dapat dikonfigurasi berdasarkan platform
  static String get baseUrl {
    // Development environment
    if (kDebugMode) {
      // Web atau emulator
      if (kIsWeb) {
        ////return 'https://ruanghijau.web.id';
        return 'http://192.168.18.122:5000';
      }

      // Android
      if (Platform.isAndroid) {
        // Gunakan 10.0.2.2 untuk Android emulator
        // Atau ganti dengan IP address PC Anda untuk physical device
        ////return 'https://ruanghijau.web.id';
        return 'http://192.168.18.122:5000';
      }

      // iOS
      if (Platform.isIOS) {
        ////return 'https://ruanghijau.web.id';
        return 'http://192.168.18.122:5000';
      }
    }

    // Production environment - gunakan domain actual
    ////return 'https://ruanghijau.web.id';
    return 'http://192.168.18.122:5000';
  }

  /// Construct full image URL dari filename
  static String getImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    }

    // Jika filename sudah berupa full URL, return as is
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }

    // Construct full URL
    return '$baseUrl/uploads/$filename';
  }

  /// Get API base URL dengan trailing slash untuk kemudahan concatenation
  static String get apiBaseUrl {
    final url = baseUrl;
    return url.endsWith('/') ? url : '$url/';
  }

  /// Construct full API endpoint URL dengan proper handling trailing slash
  static String getEndpoint(String path) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$base$cleanPath';
  }

  /// Get uploads base URL
  static String get uploadsBaseUrl => getEndpoint('uploads');

  // ============================================
  // DEBUG INFO
  // ============================================

  /// Get debug info untuk troubleshooting
  static String get debugInfo {
    return '''
Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}
Base URL: $baseUrl
API Base: $apiBaseUrl
Uploads Base: $uploadsBaseUrl
Debug Mode: $kDebugMode
''';
  }

  /// Print debug info ke console
  static void printDebugInfo() {
    print('═════════════════════════════════════════════════════════');
    print('📱 APP CONFIGURATION DEBUG INFO');
    print('═════════════════════════════════════════════════════════');
    print(debugInfo);
    print('═════════════════════════════════════════════════════════');
  }
}
