class ResultParser {
  static String categoryLabel(String category) {
    switch (category) {
      case 'product':
        return 'Product';
      case 'movie':
        return 'Movie';
      case 'show':
        return 'TV Show';
      case 'restaurant':
        return 'Restaurant';
      case 'location':
        return 'Location';
      default:
        return 'Content';
    }
  }

  static String confidenceLabel(double confidence) {
    final percent = (confidence * 100).round();
    return '$percent% confidence';
  }
}