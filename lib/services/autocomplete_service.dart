import '../models/product.dart';
import 'search_service.dart';

/// Service for providing autocomplete suggestions for product search.
///
/// Provides case-insensitive filtering and relevance-based sorting
/// with prefix matches appearing first.
///
/// Requirements: 3.2, 3.3
class AutocompleteService {
  final SearchService _searchService;

  AutocompleteService({SearchService? searchService})
      : _searchService = searchService ?? SearchService();

  /// Gets autocomplete suggestions for a query.
  ///
  /// Returns up to [maxResults] products that match the query,
  /// sorted by relevance with prefix matches first.
  ///
  /// Requirements: 1.3, 3.2, 3.3
  List<Product> getSuggestions(String query, {int maxResults = 5}) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    // Get all matching products from search service
    final matches = _searchService.search(trimmedQuery);

    // Sort by relevance (prefix matches first)
    final sorted = sortByRelevance(matches, trimmedQuery);

    // Return up to maxResults
    return sorted.take(maxResults).toList();
  }

  /// Checks if a product matches the query (case-insensitive).
  ///
  /// Returns true if the product's title contains the query string
  /// when both are compared case-insensitively.
  ///
  /// Requirements: 3.2
  bool matchesQuery(Product product, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return false;
    }

    final lowerQuery = trimmedQuery.toLowerCase();
    return product.title.toLowerCase().contains(lowerQuery);
  }

  /// Sorts products by relevance to the query.
  ///
  /// Products whose titles start with the query (case-insensitive)
  /// appear before products whose titles only contain the query elsewhere.
  ///
  /// Requirements: 3.3
  List<Product> sortByRelevance(List<Product> products, String query) {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) {
      return List.from(products);
    }

    // Separate into prefix matches and contains matches
    final prefixMatches = <Product>[];
    final containsMatches = <Product>[];

    for (final product in products) {
      final lowerTitle = product.title.toLowerCase();
      if (lowerTitle.startsWith(lowerQuery)) {
        prefixMatches.add(product);
      } else {
        containsMatches.add(product);
      }
    }

    // Return prefix matches first, then contains matches
    return [...prefixMatches, ...containsMatches];
  }
}
