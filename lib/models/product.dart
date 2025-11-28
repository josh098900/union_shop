/// Product model representing an item available for purchase.
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> imageUrls;
  final List<String> sizes;
  final List<String> colours;
  final String collectionId;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.salePrice,
    required this.imageUrls,
    required this.sizes,
    required this.colours,
    required this.collectionId,
    required this.createdAt,
  });

  /// Returns true if the product has a valid sale price lower than the original price.
  bool get isOnSale => salePrice != null && salePrice! < price;

  /// Returns the sale price if on sale, otherwise the regular price.
  double get displayPrice => isOnSale ? salePrice! : price;

  /// Creates a Product from a JSON map.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      salePrice: json['salePrice'] != null
          ? (json['salePrice'] as num).toDouble()
          : null,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      sizes: List<String>.from(json['sizes'] as List),
      colours: List<String>.from(json['colours'] as List),
      collectionId: json['collectionId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts the Product to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'imageUrls': imageUrls,
      'sizes': sizes,
      'colours': colours,
      'collectionId': collectionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Product) return false;
    return id == other.id &&
        title == other.title &&
        description == other.description &&
        price == other.price &&
        salePrice == other.salePrice &&
        _listEquals(imageUrls, other.imageUrls) &&
        _listEquals(sizes, other.sizes) &&
        _listEquals(colours, other.colours) &&
        collectionId == other.collectionId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      price,
      salePrice,
      Object.hashAll(imageUrls),
      Object.hashAll(sizes),
      Object.hashAll(colours),
      collectionId,
      createdAt,
    );
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
