// Model untuk Waste Detection Result
class WasteDetectionResult {
  final bool success;
  final DetectionData? detection;
  final ClassificationData? classification;
  final ColorAnalysis? colorAnalysis;
  final FileData? file;
  final String? message;

  WasteDetectionResult({
    required this.success,
    this.detection,
    this.classification,
    this.colorAnalysis,
    this.file,
    this.message,
  });

  factory WasteDetectionResult.fromJson(Map<String, dynamic> json) {
    return WasteDetectionResult(
      success: json['success'] ?? false,
      detection: json['detection'] != null
          ? DetectionData.fromJson(json['detection'])
          : null,
      classification: json['classification'] != null
          ? ClassificationData.fromJson(json['classification'])
          : null,
      colorAnalysis: json['color_analysis'] != null
          ? ColorAnalysis.fromJson(json['color_analysis'])
          : null,
      file: json['file'] != null ? FileData.fromJson(json['file']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'detection': detection?.toJson(),
      'classification': classification?.toJson(),
      'color_analysis': colorAnalysis?.toJson(),
      'file': file?.toJson(),
      'message': message,
    };
  }
}

// Data hasil deteksi dari AI
class DetectionData {
  final String category;
  final double confidence;
  final String detectedObject;
  final String method; // 'ml', 'keyword', 'default'

  DetectionData({
    required this.category,
    required this.confidence,
    required this.detectedObject,
    required this.method,
  });

  factory DetectionData.fromJson(Map<String, dynamic> json) {
    return DetectionData(
      category: json['category'] ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      detectedObject: json['detected_object'] ?? 'unknown',
      method: json['method'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'confidence': confidence,
      'detected_object': detectedObject,
      'method': method,
    };
  }

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(0)}%';
}

// Data klasifikasi sampah
class ClassificationData {
  final String binColor;
  final String binCode;
  final String description;
  final String icon;

  ClassificationData({
    required this.binColor,
    required this.binCode,
    required this.description,
    required this.icon,
  });

  factory ClassificationData.fromJson(Map<String, dynamic> json) {
    return ClassificationData(
      binColor: json['bin_color'] ?? '',
      binCode: json['bin_code'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bin_color': binColor,
      'bin_code': binCode,
      'description': description,
      'icon': icon,
    };
  }
}

// Analisis warna dominan
class ColorAnalysis {
  final int r;
  final int g;
  final int b;

  ColorAnalysis({required this.r, required this.g, required this.b});

  factory ColorAnalysis.fromJson(Map<String, dynamic> json) {
    return ColorAnalysis(
      r: json['r'] ?? 0,
      g: json['g'] ?? 0,
      b: json['b'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'r': r, 'g': g, 'b': b};
  }
}

// Data file
class FileData {
  final String name;
  final String path;

  FileData({required this.name, required this.path});

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(name: json['name'] ?? '', path: json['path'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path};
  }
}

// Kategori sampah (untuk list categories)
class WasteCategory {
  final String id;
  final String name;
  final String binColor;
  final String binCode;
  final String icon;
  final String description;
  final List<String> examples;

  WasteCategory({
    required this.id,
    required this.name,
    required this.binColor,
    required this.binCode,
    required this.icon,
    required this.description,
    required this.examples,
  });

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      binColor: json['bin_color'] ?? '',
      binCode: json['bin_code'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      examples: List<String>.from(json['examples'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bin_color': binColor,
      'bin_code': binCode,
      'icon': icon,
      'description': description,
      'examples': examples,
    };
  }
}

// Response untuk list categories
class WasteCategoriesResponse {
  final bool success;
  final List<WasteCategory> categories;

  WasteCategoriesResponse({required this.success, required this.categories});

  factory WasteCategoriesResponse.fromJson(Map<String, dynamic> json) {
    var list = json['categories'] as List?;
    List<WasteCategory> categories = [];
    if (list != null) {
      categories = list.map((item) => WasteCategory.fromJson(item)).toList();
    }
    return WasteCategoriesResponse(
      success: json['success'] ?? false,
      categories: categories,
    );
  }
}
