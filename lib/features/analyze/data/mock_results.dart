import 'analysis_result.dart';

class MockResults {
  static final product = AnalysisResult(
    id: 'mock-product-1',
    description: 'Dr. Martens 1460 Pascal Virginia Boots — a timeless icon of self-expression, reimagined in supple Virginia leather for all-day comfort.',
    confidence: 0.92,
    category: 'product',
    tags: const ['boots', 'dr. martens', 'fashion', 'footwear'],
    processingTimeMs: 1180,
    productLinks: const [
      ProductLink(
        title: '1460 Pascal Virginia Boots',
        price: '\$149.00',
        url: 'https://amazon.com/dp/example',
        source: 'Amazon',
        confidence: 0.95,
      ),
      ProductLink(
        title: '1460 Pascal Virginia — Official',
        price: '\$159.00',
        url: 'https://drmartens.com/example',
        source: 'Dr. Martens',
        confidence: 0.88,
      ),
      ProductLink(
        title: '1460 Pascal Virginia Boots',
        price: '\$142.50',
        url: 'https://nordstrom.com/example',
        source: 'Nordstrom',
        confidence: 0.82,
      ),
    ],
  );

  static final movie = AnalysisResult(
    id: 'mock-movie-1',
    description: 'Everything Everywhere All at Once — a mind-bending multiverse adventure that follows a Chinese-American woman as she connects with parallel lives.',
    confidence: 0.89,
    category: 'movie',
    tags: const ['sci-fi', 'adventure', 'comedy', 'acclaimed'],
    processingTimeMs: 1450,
    streamingLinks: const [
      StreamingLink(
        title: 'Everything Everywhere All at Once',
        platform: 'Netflix',
        url: 'https://netflix.com/example',
        type: 'subscription',
        confidence: 0.91,
      ),
      StreamingLink(
        title: 'Everything Everywhere All at Once',
        platform: 'Apple TV',
        url: 'https://tv.apple.com/example',
        type: 'rent',
        confidence: 0.87,
      ),
      StreamingLink(
        title: 'Everything Everywhere All at Once',
        platform: 'Amazon',
        url: 'https://amazon.com/example',
        type: 'buy',
        confidence: 0.84,
      ),
    ],
  );

  static final mixed = AnalysisResult(
    id: 'mock-mixed-1',
    description: 'Bose QuietComfort Ultra Headphones — immersive sound with world-class noise cancellation and spatial audio.',
    confidence: 0.94,
    category: 'product',
    tags: const ['headphones', 'bose', 'audio', 'noise-cancelling'],
    processingTimeMs: 980,
    productLinks: const [
      ProductLink(
        title: 'QC Ultra Headphones',
        price: '\$379.00',
        url: 'https://amazon.com/dp/example',
        source: 'Amazon',
        confidence: 0.96,
      ),
      ProductLink(
        title: 'QC Ultra Headphones',
        price: '\$399.00',
        url: 'https://bose.com/example',
        source: 'Bose',
        confidence: 0.93,
      ),
    ],
    streamingLinks: const [],
  );
}
