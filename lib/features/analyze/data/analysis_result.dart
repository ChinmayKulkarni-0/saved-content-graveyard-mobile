class AnalysisResult {
  final String id;
  final String description;
  final double confidence;
  final String category;
  final String? rawText;
  final List<ProductLink> productLinks;
  final List<StreamingLink> streamingLinks;
  final List<String> tags;
  final double processingTimeMs;

  const AnalysisResult({
    required this.id,
    required this.description,
    required this.confidence,
    required this.category,
    this.rawText,
    this.productLinks = const [],
    this.streamingLinks = const [],
    this.tags = const [],
    required this.processingTimeMs,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'unknown',
      rawText: json['raw_text'] as String?,
      productLinks: (json['product_links'] as List<dynamic>? ?? [])
          .map((e) => ProductLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      streamingLinks: (json['streaming_links'] as List<dynamic>? ?? [])
          .map((e) => StreamingLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      processingTimeMs:
          (json['processing_time_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProductLink {
  final String title;
  final String? price;
  final String url;
  final String source;
  final double confidence;

  const ProductLink({
    required this.title,
    this.price,
    required this.url,
    required this.source,
    required this.confidence,
  });

  factory ProductLink.fromJson(Map<String, dynamic> json) {
    return ProductLink(
      title: json['title'] as String,
      price: json['price'] as String?,
      url: json['url'] as String,
      source: json['source'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StreamingLink {
  final String title;
  final String platform;
  final String url;
  final String type;
  final double confidence;

  const StreamingLink({
    required this.title,
    required this.platform,
    required this.url,
    required this.type,
    required this.confidence,
  });

  factory StreamingLink.fromJson(Map<String, dynamic> json) {
    return StreamingLink(
      title: json['title'] as String,
      platform: json['platform'] as String,
      url: json['url'] as String,
      type: json['type'] as String? ?? 'subscription',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}