import '../models/product.dart';
import '../models/collection.dart';
import '../widgets/sort_dropdown.dart';

/// Filter criteria for products.
class ProductFilter {
  final String? size;
  final String? colour;
  final String? collectionId;

  const ProductFilter({
    this.size,
    this.colour,
    this.collectionId,
  });

  /// Returns true if no filters are applied.
  bool get isEmpty => size == null && colour == null && collectionId == null;
}

/// Filter criteria for collections.
class CollectionFilter {
  final bool? isSaleCollection;

  const CollectionFilter({
    this.isSaleCollection,
  });

  /// Returns true if no filters are applied.
  bool get isEmpty => isSaleCollection == null;
}

/// Service for sorting and filtering products and collections.
class FilterService {
  // ============ Product Sorting ============

  /// Sorts a list of products by the given sort option.
  /// Returns a new sorted list without modifying the original.
  List<Product> sortProducts(List<Product> products, SortOption sortOption) {
    final sorted = List<Product>.from(products);
    switch (sortOption) {
      case SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
        break;
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return sorted;
  }


  // ============ Product Filtering ============

  /// Filters a list of products by the given filter criteria.
  /// Returns a new filtered list without modifying the original.
  List<Product> filterProducts(List<Product> products, ProductFilter filter) {
    if (filter.isEmpty) return List.from(products);

    return products.where((product) {
      // Filter by size
      if (filter.size != null && !product.sizes.contains(filter.size)) {
        return false;
      }
      // Filter by colour
      if (filter.colour != null && !product.colours.contains(filter.colour)) {
        return false;
      }
      // Filter by collection
      if (filter.collectionId != null && product.collectionId != filter.collectionId) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Applies both filtering and sorting to a list of products.
  List<Product> filterAndSortProducts(
    List<Product> products,
    ProductFilter filter,
    SortOption sortOption,
  ) {
    final filtered = filterProducts(products, filter);
    return sortProducts(filtered, sortOption);
  }

  // ============ Collection Sorting ============

  /// Sorts a list of collections by the given sort option.
  /// Returns a new sorted list without modifying the original.
  List<Collection> sortCollections(List<Collection> collections, SortOption sortOption) {
    final sorted = List<Collection>.from(collections);
    switch (sortOption) {
      case SortOption.newest:
        // Collections don't have createdAt, so we keep original order
        break;
      case SortOption.priceAsc:
        // Collections don't have price, so we keep original order
        break;
      case SortOption.priceDesc:
        // Collections don't have price, so we keep original order
        break;
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return sorted;
  }

  // ============ Collection Filtering ============

  /// Filters a list of collections by the given filter criteria.
  /// Returns a new filtered list without modifying the original.
  List<Collection> filterCollections(List<Collection> collections, CollectionFilter filter) {
    if (filter.isEmpty) return List.from(collections);

    return collections.where((collection) {
      // Filter by sale collection status
      if (filter.isSaleCollection != null && 
          collection.isSaleCollection != filter.isSaleCollection) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Applies both filtering and sorting to a list of collections.
  List<Collection> filterAndSortCollections(
    List<Collection> collections,
    CollectionFilter filter,
    SortOption sortOption,
  ) {
    final filtered = filterCollections(collections, filter);
    return sortCollections(filtered, sortOption);
  }

  // ============ Helper Methods ============

  /// Extracts all unique sizes from a list of products.
  Set<String> getAvailableSizes(List<Product> products) {
    final sizes = <String>{};
    for (final product in products) {
      sizes.addAll(product.sizes);
    }
    return sizes;
  }

  /// Extracts all unique colours from a list of products.
  Set<String> getAvailableColours(List<Product> products) {
    final colours = <String>{};
    for (final product in products) {
      colours.addAll(product.colours);
    }
    return colours;
  }
}
