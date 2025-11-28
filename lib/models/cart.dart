import 'cart_item.dart';
import 'product.dart';

/// Cart model representing the shopping cart with items and calculated totals.
class Cart {
  final List<CartItem> items;

  /// Tax rate (20% VAT).
  static const double taxRate = 0.20;

  const Cart({required this.items});

  /// Creates an empty cart.
  const Cart.empty() : items = const [];

  /// Calculates the subtotal (sum of all item totals before tax).
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Calculates the tax amount (20% VAT).
  double get tax => subtotal * taxRate;

  /// Calculates the total (subtotal + tax).
  double get total => subtotal + tax;

  /// Returns the total number of items in the cart.
  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Returns true if the cart has no items.
  bool get isEmpty => items.isEmpty;

  /// Creates a Cart from a JSON map.
  /// Requires a product lookup function to resolve products from productIds.
  factory Cart.fromJson(
    Map<String, dynamic> json,
    Product Function(String productId) productLookup,
  ) {
    final itemsList = json['items'] as List;
    return Cart(
      items: itemsList
          .map((item) => CartItem.fromJson(
                item as Map<String, dynamic>,
                productLookup,
              ))
          .toList(),
    );
  }

  /// Converts the Cart to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Creates a copy of this Cart with the given fields replaced.
  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Cart) return false;
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);
}
