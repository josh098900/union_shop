import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

/// Provider for managing cart state across the application.
///
/// Extends ChangeNotifier to notify listeners when cart state changes.
class CartProvider extends ChangeNotifier {
  final CartService _cartService;
  Cart _cart = const Cart.empty();
  bool _isLoading = false;
  String? _error;

  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  /// The current cart state.
  Cart get cart => _cart;

  /// Whether the cart is currently loading.
  bool get isLoading => _isLoading;

  /// The last error message, if any.
  String? get error => _error;

  /// Convenience getters for cart properties.
  List get items => _cart.items;
  double get subtotal => _cart.subtotal;
  double get tax => _cart.tax;
  double get total => _cart.total;
  int get itemCount => _cart.itemCount;
  bool get isEmpty => _cart.isEmpty;

  /// Loads the cart from persistent storage.
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _cartService.load();
    } catch (e) {
      _error = 'Failed to load cart';
      _cart = const Cart.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Adds a product to the cart with the specified options.
  Future<void> addToCart(
    Product product, {
    required int quantity,
    String? selectedSize,
    String? selectedColour,
    String? customText,
  }) async {
    _error = null;

    _cart = _cartService.add(
      _cart,
      product,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColour: selectedColour,
      customText: customText,
    );

    // Persist to storage first, then notify listeners
    final saved = await _cartService.save(_cart);
    if (!saved) {
      _error = 'Failed to save cart';
    }
    
    // Notify after save completes to ensure UI updates with persisted state
    notifyListeners();
  }

  /// Removes an item from the cart by its ID.
  Future<void> removeFromCart(String itemId) async {
    _error = null;

    _cart = _cartService.remove(_cart, itemId);
    notifyListeners();

    // Persist to storage
    final saved = await _cartService.save(_cart);
    if (!saved) {
      _error = 'Failed to save cart';
      notifyListeners();
    }
  }

  /// Updates the quantity of a cart item.
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    _error = null;

    _cart = _cartService.updateQuantity(_cart, itemId, newQuantity);
    notifyListeners();

    // Persist to storage
    final saved = await _cartService.save(_cart);
    if (!saved) {
      _error = 'Failed to save cart';
      notifyListeners();
    }
  }

  /// Clears all items from the cart.
  Future<void> clearCart() async {
    _error = null;

    _cart = _cartService.clear(_cart);
    notifyListeners();

    // Persist to storage
    final saved = await _cartService.save(_cart);
    if (!saved) {
      _error = 'Failed to save cart';
      notifyListeners();
    }
  }

  /// Clears any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
