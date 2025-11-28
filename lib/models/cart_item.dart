import 'product.dart';

/// CartItem model representing a product in the shopping cart with selected options.
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColour;
  final String? customText;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColour,
    this.customText,
  });

  /// Calculates the total price for this cart item.
  double get totalPrice => product.displayPrice * quantity;

  /// Creates a CartItem from a JSON map.
  /// Requires a product lookup function to resolve the product from productId.
  factory CartItem.fromJson(
    Map<String, dynamic> json,
    Product Function(String productId) productLookup,
  ) {
    final productId = json['productId'] as String;
    return CartItem(
      id: json['id'] as String,
      product: productLookup(productId),
      quantity: json['quantity'] as int,
      selectedSize: json['selectedSize'] as String?,
      selectedColour: json['selectedColour'] as String?,
      customText: json['customText'] as String?,
    );
  }

  /// Converts the CartItem to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': product.id,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColour': selectedColour,
      'customText': customText,
    };
  }

  /// Creates a copy of this CartItem with the given fields replaced.
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColour,
    String? customText,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColour: selectedColour ?? this.selectedColour,
      customText: customText ?? this.customText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CartItem) return false;
    return id == other.id &&
        product == other.product &&
        quantity == other.quantity &&
        selectedSize == other.selectedSize &&
        selectedColour == other.selectedColour &&
        customText == other.customText;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      product,
      quantity,
      selectedSize,
      selectedColour,
      customText,
    );
  }
}
