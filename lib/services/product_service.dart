import '../models/product.dart';

/// Service for managing product data.
///
/// Provides methods to retrieve products from an in-memory data store.
class ProductService {
  /// In-memory product data store with realistic product data.
  static final List<Product> _products = [
    // Clothing collection products
    Product(
      id: 'prod-1',
      title: 'University Hoodie',
      description: 'Classic university hoodie with embroidered logo.',
      price: 35.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['S', 'M', 'L', 'XL'],
      colours: ['Navy', 'Black', 'Grey'],
      collectionId: 'clothing',
      createdAt: DateTime(2025, 1, 15),
    ),
    Product(
      id: 'prod-2',
      title: 'Portsmouth T-Shirt',
      description: 'Comfortable cotton t-shirt with printed design.',
      price: 18.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colours: ['White', 'Black', 'Navy'],
      collectionId: 'clothing',
      createdAt: DateTime(2025, 2, 10),
    ),
    Product(
      id: 'prod-3',
      title: 'Campus Jacket',
      description: 'Lightweight jacket perfect for campus life.',
      price: 55.00,
      salePrice: 45.00,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['S', 'M', 'L', 'XL'],
      colours: ['Black', 'Navy'],
      collectionId: 'clothing',
      createdAt: DateTime(2025, 3, 5),
    ),
    Product(
      id: 'prod-4',
      title: 'Varsity Sweatshirt',
      description: 'Premium sweatshirt with varsity-style lettering.',
      price: 42.00,
      salePrice: 35.00,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['S', 'M', 'L', 'XL'],
      colours: ['Grey', 'Navy', 'Black'],
      collectionId: 'clothing',
      createdAt: DateTime(2025, 3, 15),
    ),
    // Accessories collection products
    Product(
      id: 'prod-5',
      title: 'Student Beanie',
      description: 'Warm knitted beanie with university branding.',
      price: 12.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['One Size'],
      colours: ['Navy', 'Black', 'Purple'],
      collectionId: 'accessories',
      createdAt: DateTime(2025, 1, 20),
    ),
    Product(
      id: 'prod-6',
      title: 'Portsmouth Scarf',
      description: 'Soft scarf with university colours.',
      price: 15.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['One Size'],
      colours: ['Purple', 'Navy'],
      collectionId: 'accessories',
      createdAt: DateTime(2025, 2, 1),
    ),
    Product(
      id: 'prod-7',
      title: 'Campus Backpack',
      description: 'Durable backpack with laptop compartment.',
      price: 45.00,
      salePrice: 38.00,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['One Size'],
      colours: ['Black', 'Navy', 'Grey'],
      collectionId: 'accessories',
      createdAt: DateTime(2025, 2, 15),
    ),
    // Souvenirs collection products
    Product(
      id: 'prod-8',
      title: 'Portsmouth Magnet',
      description: 'Collectible magnet featuring Portsmouth landmarks.',
      price: 5.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['One Size'],
      colours: ['Multi'],
      collectionId: 'souvenirs',
      createdAt: DateTime(2025, 1, 10),
    ),
    Product(
      id: 'prod-9',
      title: 'University Mug',
      description: 'Ceramic mug with university crest.',
      price: 10.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['Standard'],
      colours: ['White', 'Navy'],
      collectionId: 'souvenirs',
      createdAt: DateTime(2025, 1, 25),
    ),
    Product(
      id: 'prod-10',
      title: 'Portsmouth Postcard Set',
      description: 'Set of 6 postcards featuring campus views.',
      price: 8.00,
      salePrice: 6.00,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['Standard'],
      colours: ['Multi'],
      collectionId: 'souvenirs',
      createdAt: DateTime(2025, 2, 5),
    ),
    // Stationery collection products
    Product(
      id: 'prod-11',
      title: 'University Notebook',
      description: 'A5 notebook with university branding.',
      price: 8.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['A5', 'A4'],
      colours: ['Navy', 'Purple'],
      collectionId: 'stationery',
      createdAt: DateTime(2025, 1, 5),
    ),
    Product(
      id: 'prod-12',
      title: 'Portsmouth Pen Set',
      description: 'Set of 3 branded ballpoint pens.',
      price: 6.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['Standard'],
      colours: ['Blue', 'Black'],
      collectionId: 'stationery',
      createdAt: DateTime(2025, 1, 12),
    ),
    Product(
      id: 'prod-13',
      title: 'Student Planner',
      description: 'Academic year planner with university calendar.',
      price: 15.00,
      salePrice: 12.00,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['A5'],
      colours: ['Navy', 'Purple', 'Black'],
      collectionId: 'stationery',
      createdAt: DateTime(2025, 2, 20),
    ),
    // Print Shack products
    Product(
      id: 'print-shack-tshirt',
      title: 'Custom T-Shirt',
      description: 'Personalised t-shirt with your custom text.',
      price: 22.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['S', 'M', 'L', 'XL'],
      colours: ['White', 'Black', 'Red', 'Blue', 'Gold'],
      collectionId: 'print-shack',
      createdAt: DateTime(2025, 3, 1),
    ),
    Product(
      id: 'print-shack-hoodie',
      title: 'Custom Hoodie',
      description: 'Personalised hoodie with your custom text.',
      price: 38.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['S', 'M', 'L', 'XL'],
      colours: ['White', 'Black', 'Gold'],
      collectionId: 'print-shack',
      createdAt: DateTime(2025, 3, 1),
    ),
    Product(
      id: 'print-shack-mug',
      title: 'Custom Mug',
      description: 'Personalised ceramic mug with your custom text.',
      price: 14.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['Standard'],
      colours: ['Black', 'Blue', 'Red', 'Green'],
      collectionId: 'print-shack',
      createdAt: DateTime(2025, 3, 1),
    ),
    Product(
      id: 'print-shack-totebag',
      title: 'Custom Tote Bag',
      description: 'Personalised tote bag with your custom text.',
      price: 16.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'],
      sizes: ['One Size'],
      colours: ['Black', 'Navy', 'Brown'],
      collectionId: 'print-shack',
      createdAt: DateTime(2025, 3, 1),
    ),
    Product(
      id: 'print-shack-cap',
      title: 'Custom Cap',
      description: 'Personalised cap with your custom text.',
      price: 18.00,
      salePrice: null,
      imageUrls: ['https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'],
      sizes: ['One Size'],
      colours: ['White', 'Black'],
      collectionId: 'print-shack',
      createdAt: DateTime(2025, 3, 1),
    ),
  ];

  /// Returns all products.
  List<Product> getAll() {
    return List.unmodifiable(_products);
  }

  /// Returns a product by its ID, or null if not found.
  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all products belonging to a specific collection.
  List<Product> getByCollection(String collectionId) {
    return _products.where((p) => p.collectionId == collectionId).toList();
  }

  /// Searches products by title or description (case-insensitive).
  List<Product> search(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _products.where((p) {
      return p.title.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Returns all products that are on sale.
  List<Product> getSaleProducts() {
    return _products.where((p) => p.isOnSale).toList();
  }
}
