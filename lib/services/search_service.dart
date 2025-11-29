import '../models/product.dart';
import 'product_service.dart';

/// Service for searching products across the catalog.
///
/// Provides case-insensitive search across product titles and descriptions.
///
/// Requirements: 19.1, 19.2, 19.3
class SearchService {
  final ProductService _productService;

  SearchService({ProductService? productService})
      : _productService = productService ?? ProductService();

  /// Searches products by query string (case-insensitive).
  ///
  /// Searches across product titles and descriptions.
  /// Returns an empty list if the query is empty or whitespace-only.
  ///
  /// Requirements: 19.1, 19.2, 19.3
  List<Product> search(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final lowerQuery = trimmedQuery.toLowerCase();
    final allProducts = _productService.getAll();

    return allProducts.where((product) {
      final titleMatch = product.title.toLowerCase().contains(lowerQuery);
      final descriptionMatch =
          product.description.toLowerCase().contains(lowerQuery);
      return titleMatch || descriptionMatch;
    }).toList();
  }

  /// Checks if a product matches a search query.
  ///
  /// Returns true if the product's title or description contains
  /// the query string (case-insensitive).
  bool productMatchesQuery(Product product, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return false;
    }

    final lowerQuery = trimmedQuery.toLowerCase();
    return product.title.toLowerCase().contains(lowerQuery) ||
        product.description.toLowerCase().contains(lowerQuery);
  }
}
