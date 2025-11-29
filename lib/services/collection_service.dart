import '../models/collection.dart';

/// Service for managing collection data.
///
/// Provides methods to retrieve collections from an in-memory data store.
class CollectionService {
  /// In-memory collection data store with realistic collection data.
  static final List<Collection> _collections = [
    const Collection(
      id: 'clothing',
      title: 'Clothing',
      description: 'Official University of Portsmouth apparel including hoodies, t-shirts, and more.',
      imageUrl: 'https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282',
      isSaleCollection: false,
    ),
    const Collection(
      id: 'souvenirs',
      title: 'Souvenirs',
      description: 'Memorable keepsakes and gifts featuring Portsmouth landmarks.',
      imageUrl: 'https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561',
      isSaleCollection: false,
    ),
    const Collection(
      id: 'accessories',
      title: 'Accessories',
      description: 'Bags, hats, scarves and other accessories with university branding.',
      imageUrl: 'https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282',
      isSaleCollection: false,
    ),
    const Collection(
      id: 'stationery',
      title: 'Stationery',
      description: 'Notebooks, pens, and other stationery items for students.',
      imageUrl: 'https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561',
      isSaleCollection: false,
    ),
    const Collection(
      id: 'sale',
      title: 'Sale',
      description: 'Discounted items and special offers.',
      imageUrl: 'https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282',
      isSaleCollection: true,
    ),
  ];

  /// Returns all collections.
  List<Collection> getAll() {
    return List.unmodifiable(_collections);
  }

  /// Returns a collection by its ID, or null if not found.
  Collection? getById(String id) {
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all non-sale collections.
  List<Collection> getNonSaleCollections() {
    return _collections.where((c) => !c.isSaleCollection).toList();
  }

  /// Returns the sale collection if it exists.
  Collection? getSaleCollection() {
    try {
      return _collections.firstWhere((c) => c.isSaleCollection);
    } catch (_) {
      return null;
    }
  }
}
