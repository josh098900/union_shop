import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/models/cart_item.dart';
import 'package:union_shop/models/cart.dart';
import 'package:union_shop/providers/cart_provider.dart';
import 'package:union_shop/services/cart_service.dart';
import 'package:union_shop/pages/cart_page.dart';
import 'package:union_shop/widgets/cart_item_widget.dart';

/// Helper to create a product with given id and price
Product createTestProduct({
  required String id,
  required double price,
  double? salePrice,
  String? title,
}) {
  return Product(
    id: id,
    title: title ?? 'Test Product $id',
    description: 'Test description for product $id',
    price: price,
    salePrice: salePrice,
    imageUrls: ['https://example.com/image.jpg'],
    sizes: ['S', 'M', 'L'],
    colours: ['Red', 'Blue'],
    collectionId: 'collection-1',
    createdAt: DateTime.now(),
  );
}

/// Helper to create a cart item
CartItem createTestCartItem({
  required String id,
  required Product product,
  required int quantity,
  String? selectedSize,
  String? selectedColour,
  String? customText,
}) {
  return CartItem(
    id: id,
    product: product,
    quantity: quantity,
    selectedSize: selectedSize,
    selectedColour: selectedColour,
    customText: customText,
  );
}

/// Test CartProvider that allows setting cart state directly
class TestCartProvider extends ChangeNotifier implements CartProvider {
  Cart _cart;
  bool _isLoading = false;
  String? _error;
  final CartService _cartService = CartService();

  TestCartProvider({Cart? initialCart}) : _cart = initialCart ?? const Cart.empty();

  @override
  Cart get cart => _cart;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  List get items => _cart.items;

  @override
  double get subtotal => _cart.subtotal;

  @override
  double get tax => _cart.tax;

  @override
  double get total => _cart.total;

  @override
  int get itemCount => _cart.itemCount;

  @override
  bool get isEmpty => _cart.isEmpty;

  void setCart(Cart cart) {
    _cart = cart;
    notifyListeners();
  }

  @override
  Future<void> loadCart() async {
    // No-op for testing
  }

  @override
  Future<void> addToCart(
    Product product, {
    required int quantity,
    String? selectedSize,
    String? selectedColour,
    String? customText,
  }) async {
    _cart = _cartService.add(
      _cart,
      product,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColour: selectedColour,
      customText: customText,
    );
    notifyListeners();
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    _cart = _cartService.remove(_cart, itemId);
    notifyListeners();
  }

  @override
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    _cart = _cartService.updateQuantity(_cart, itemId, newQuantity);
    notifyListeners();
  }

  @override
  Future<void> clearCart() async {
    _cart = const Cart.empty();
    notifyListeners();
  }

  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Wraps a widget with necessary providers for testing
Widget createTestWidget({required Widget child, required CartProvider cartProvider}) {
  return ChangeNotifierProvider<CartProvider>.value(
    value: cartProvider,
    child: MaterialApp(
      home: child,
      routes: {
        '/collections': (context) => const Scaffold(body: Text('Collections')),
      },
    ),
  );
}

void main() {
  group('CartPage Widget Tests', () {
    testWidgets('displays empty cart state when cart is empty', (tester) async {
      final cartProvider = TestCartProvider(initialCart: const Cart.empty());

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      // Verify empty cart message is displayed
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('displays cart items when cart has items', (tester) async {
      final product = createTestProduct(id: 'prod-1', price: 25.00);
      final cartItem = createTestCartItem(
        id: 'item-1',
        product: product,
        quantity: 2,
        selectedSize: 'M',
        selectedColour: 'Red',
      );
      final cart = Cart(items: [cartItem]);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      // Verify cart item is displayed
      expect(find.byType(CartItemWidget), findsOneWidget);
      expect(find.text('Shopping Cart'), findsOneWidget);
    });

    testWidgets('displays order summary with correct totals', (tester) async {
      final product = createTestProduct(id: 'prod-1', price: 10.00);
      final cartItem = createTestCartItem(
        id: 'item-1',
        product: product,
        quantity: 2,
      );
      final cart = Cart(items: [cartItem]);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      // Verify totals are displayed (subtotal = 20.00, tax = 4.00, total = 24.00)
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('£20.00'), findsWidgets); // Subtotal
      expect(find.text('£4.00'), findsOneWidget); // Tax
      expect(find.text('£24.00'), findsOneWidget); // Total
    });

    testWidgets('displays checkout button', (tester) async {
      final product = createTestProduct(id: 'prod-1', price: 10.00);
      final cartItem = createTestCartItem(
        id: 'item-1',
        product: product,
        quantity: 1,
      );
      final cart = Cart(items: [cartItem]);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      // Verify checkout button is present
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });
  });

  group('Cart Display Completeness Property Tests', () {
    // **Feature: union-shop-ecommerce, Property 9: Cart Display Completeness**
    // **Validates: Requirements 14.2**
    //
    // Property: For any cart state with N items, the cart page SHALL render
    // exactly N cart item widgets, each displaying the correct product information.

    // Test with 1 item
    testWidgets('Property 9: Cart with 1 item renders exactly 1 CartItemWidget', (tester) async {
      final itemCount = 1;
      final cartItems = List.generate(itemCount, (index) {
        final product = createTestProduct(
          id: 'prod-$index',
          price: 10.0 + index,
          title: 'Product $index',
        );
        return createTestCartItem(
          id: 'item-$index',
          product: product,
          quantity: 1,
          selectedSize: 'M',
        );
      });

      final cart = Cart(items: cartItems);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CartItemWidget), findsNWidgets(itemCount));
    });

    // Test with 2 items
    testWidgets('Property 9: Cart with 2 items renders exactly 2 CartItemWidgets', (tester) async {
      final itemCount = 2;
      final cartItems = List.generate(itemCount, (index) {
        final product = createTestProduct(
          id: 'prod-$index',
          price: 10.0 + index,
          title: 'Product $index',
        );
        return createTestCartItem(
          id: 'item-$index',
          product: product,
          quantity: 1,
          selectedSize: 'M',
        );
      });

      final cart = Cart(items: cartItems);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CartItemWidget), findsNWidgets(itemCount));
    });

    // Test with 3 items
    testWidgets('Property 9: Cart with 3 items renders exactly 3 CartItemWidgets', (tester) async {
      final itemCount = 3;
      final cartItems = List.generate(itemCount, (index) {
        final product = createTestProduct(
          id: 'prod-$index',
          price: 10.0 + index,
          title: 'Product $index',
        );
        return createTestCartItem(
          id: 'item-$index',
          product: product,
          quantity: 1,
          selectedSize: 'M',
        );
      });

      final cart = Cart(items: cartItems);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CartItemWidget), findsNWidgets(itemCount));
    });

    // Test with 5 items
    testWidgets('Property 9: Cart with 5 items renders exactly 5 CartItemWidgets', (tester) async {
      final itemCount = 5;
      final cartItems = List.generate(itemCount, (index) {
        final product = createTestProduct(
          id: 'prod-$index',
          price: 10.0 + index,
          title: 'Product $index',
        );
        return createTestCartItem(
          id: 'item-$index',
          product: product,
          quantity: 1,
          selectedSize: 'M',
        );
      });

      final cart = Cart(items: cartItems);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CartItemWidget), findsNWidgets(itemCount));
    });

    // Test that each item displays correct product information
    testWidgets('Property 9: Each CartItemWidget displays correct product title', (tester) async {
      final products = [
        createTestProduct(id: 'prod-1', price: 15.00, title: 'Alpha Product'),
        createTestProduct(id: 'prod-2', price: 25.00, title: 'Beta Product'),
        createTestProduct(id: 'prod-3', price: 35.00, title: 'Gamma Product'),
      ];

      final cartItems = products.asMap().entries.map((entry) {
        return createTestCartItem(
          id: 'item-${entry.key}',
          product: entry.value,
          quantity: 1,
          selectedSize: 'M',
        );
      }).toList();

      final cart = Cart(items: cartItems);
      final cartProvider = TestCartProvider(initialCart: cart);

      await tester.pumpWidget(createTestWidget(
        child: const CartPage(),
        cartProvider: cartProvider,
      ));
      await tester.pumpAndSettle();

      // Verify each product title is displayed
      expect(find.text('Alpha Product'), findsOneWidget);
      expect(find.text('Beta Product'), findsOneWidget);
      expect(find.text('Gamma Product'), findsOneWidget);
    });
  });
}
