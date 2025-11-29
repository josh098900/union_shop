import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'product_service.dart';

/// Service for managing shopping cart operations with local storage persistence.
///
/// Provides methods to add, remove, update, clear, load, and save cart items.
class CartService {
  static const String _cartKey = 'union_shop_cart';

  final ProductService _productService;

  CartService({ProductService? productService})
      : _productService = productService ?? ProductService();

  /// Adds a product to the cart with the specified options and quantity.
  ///
  /// If an item with the same product and options already exists, the quantity
  /// is increased. Otherwise, a new cart item is created.
  Cart add(
    Cart cart,
    Product product, {
    required int quantity,
    String? selectedSize,
    String? selectedColour,
    String? customText,
  }) {
    // Check if item with same product and options exists
    final existingIndex = cart.items.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedSize == selectedSize &&
        item.selectedColour == selectedColour &&
        item.customText == customText);

    if (existingIndex >= 0) {
      // Update existing item quantity
      final existingItem = cart.items[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      final updatedItems = List<CartItem>.from(cart.items);
      updatedItems[existingIndex] = updatedItem;
      return cart.copyWith(items: updatedItems);
    } else {
      // Add new item
      final newItem = CartItem(
        id: _generateItemId(),
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColour: selectedColour,
        customText: customText,
      );
      return cart.copyWith(items: [...cart.items, newItem]);
    }
  }


  /// Removes an item from the cart by its ID.
  Cart remove(Cart cart, String itemId) {
    final updatedItems = cart.items.where((item) => item.id != itemId).toList();
    return cart.copyWith(items: updatedItems);
  }

  /// Updates the quantity of a cart item.
  ///
  /// If the new quantity is 0 or less, the item is removed from the cart.
  Cart updateQuantity(Cart cart, String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      return remove(cart, itemId);
    }

    final updatedItems = cart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    return cart.copyWith(items: updatedItems);
  }

  /// Clears all items from the cart.
  Cart clear(Cart cart) {
    return const Cart.empty();
  }

  /// Loads the cart from local storage.
  ///
  /// Returns an empty cart if no saved cart exists or if loading fails.
  Future<Cart> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Reload to get latest data on web
      await prefs.reload();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null || cartJson.isEmpty) {
        return const Cart.empty();
      }

      final json = jsonDecode(cartJson) as Map<String, dynamic>;
      return Cart.fromJson(json, _productLookup);
    } catch (e) {
      debugPrint('CartService.load error: $e');
      // Return empty cart on any error
      return const Cart.empty();
    }
  }

  /// Saves the cart to local storage.
  Future<bool> save(Cart cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cart.toJson());
      final result = await prefs.setString(_cartKey, cartJson);
      // Force a reload to ensure data is persisted on web
      await prefs.reload();
      return result;
    } catch (e) {
      debugPrint('CartService.save error: $e');
      return false;
    }
  }

  /// Looks up a product by ID using the product service.
  Product _productLookup(String productId) {
    final product = _productService.getById(productId);
    if (product == null) {
      throw Exception('Product not found: $productId');
    }
    return product;
  }

  /// Generates a unique ID for a cart item.
  String _generateItemId() {
    return 'cart-item-${DateTime.now().millisecondsSinceEpoch}';
  }
}
