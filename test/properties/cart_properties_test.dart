import 'package:test/test.dart';
import 'package:glados/glados.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/models/cart_item.dart';
import 'package:union_shop/models/cart.dart';
import 'package:union_shop/services/cart_service.dart';

/// Helper to create a product with given price and optional sale price
Product createProduct({
  required String id,
  required double price,
  double? salePrice,
}) {
  return Product(
    id: id,
    title: 'Test Product $id',
    description: 'Test description',
    price: price,
    salePrice: salePrice,
    imageUrls: ['https://example.com/image.jpg'],
    sizes: ['S', 'M', 'L'],
    colours: ['Red', 'Blue'],
    collectionId: 'collection-1',
    createdAt: DateTime.now(),
  );
}

void main() {
  group('Cart Properties', () {
    // **Feature: union-shop-ecommerce, Property 14: Cart Persistence Round-Trip**
    // **Validates: Requirements 18.4**
    Glados2(any.positiveDoubleOrZero, any.intInRange(1, 10)).test(
      'Property 14: Cart serialization round-trip preserves cart state',
      (price, quantity) {
        // Ensure price is positive
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        // Create a product lookup map
        final productMap = {product.id: product};
        Product productLookup(String id) => productMap[id]!;

        // Create cart items with the product
        final cartItem1 = CartItem(
          id: 'item-1',
          product: product,
          quantity: quantity,
          selectedSize: 'M',
          selectedColour: 'Red',
          customText: null,
        );
        final cartItem2 = CartItem(
          id: 'item-2',
          product: product,
          quantity: 1,
          selectedSize: 'L',
          selectedColour: 'Blue',
          customText: 'Custom',
        );

        final originalCart = Cart(items: [cartItem1, cartItem2]);

        // Serialize to JSON
        final json = originalCart.toJson();

        // Deserialize from JSON
        final restoredCart = Cart.fromJson(json, productLookup);

        // Verify items are preserved
        expect(restoredCart.items.length, equals(originalCart.items.length));

        for (int i = 0; i < originalCart.items.length; i++) {
          final original = originalCart.items[i];
          final restored = restoredCart.items[i];

          expect(restored.id, equals(original.id));
          expect(restored.product.id, equals(original.product.id));
          expect(restored.quantity, equals(original.quantity));
          expect(restored.selectedSize, equals(original.selectedSize));
          expect(restored.selectedColour, equals(original.selectedColour));
          expect(restored.customText, equals(original.customText));
        }

        // Verify calculated totals match
        expect(restoredCart.subtotal, closeTo(originalCart.subtotal, 0.001));
        expect(restoredCart.tax, closeTo(originalCart.tax, 0.001));
        expect(restoredCart.total, closeTo(originalCart.total, 0.001));
      },
    );

    // **Feature: union-shop-ecommerce, Property 13: Cart Total Calculation Accuracy**
    // **Validates: Requirements 18.3**
    Glados2(any.positiveDoubleOrZero, any.intInRange(1, 10)).test(
      'Property 13: Cart total calculation is accurate',
      (price, quantity) {
        // Ensure price is positive
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        final cartItem = CartItem(
          id: 'item-1',
          product: product,
          quantity: quantity,
          selectedSize: 'M',
          selectedColour: 'Red',
        );

        final cart = Cart(items: [cartItem]);

        // Verify subtotal = sum of (item.price × item.quantity)
        final expectedSubtotal = product.displayPrice * quantity;
        expect(cart.subtotal, closeTo(expectedSubtotal, 0.001));

        // Verify tax = subtotal × 0.20
        final expectedTax = expectedSubtotal * 0.20;
        expect(cart.tax, closeTo(expectedTax, 0.001));

        // Verify total = subtotal + tax
        final expectedTotal = expectedSubtotal + expectedTax;
        expect(cart.total, closeTo(expectedTotal, 0.001));
      },
    );

    // Test with sale prices
    Glados3(
      any.positiveDoubleOrZero,
      any.positiveDoubleOrZero,
      any.intInRange(1, 10),
    ).test(
      'Property 13: Cart total with sale prices is accurate',
      (price, salePrice, quantity) {
        // Ensure price is positive and salePrice is less than price
        final validPrice = price > 0 ? price : 1.0;
        final validSalePrice = salePrice < validPrice ? salePrice : null;
        final product = createProduct(
          id: 'prod-1',
          price: validPrice,
          salePrice: validSalePrice,
        );

        final cartItem = CartItem(
          id: 'item-1',
          product: product,
          quantity: quantity,
          selectedSize: 'M',
          selectedColour: 'Red',
        );

        final cart = Cart(items: [cartItem]);

        // Verify subtotal uses displayPrice (sale price if on sale)
        final expectedSubtotal = product.displayPrice * quantity;
        expect(cart.subtotal, closeTo(expectedSubtotal, 0.001));

        // Verify tax = subtotal × 0.20
        final expectedTax = expectedSubtotal * Cart.taxRate;
        expect(cart.tax, closeTo(expectedTax, 0.001));

        // Verify total = subtotal + tax
        final expectedTotal = expectedSubtotal + expectedTax;
        expect(cart.total, closeTo(expectedTotal, 0.001));
      },
    );

    // Test with multiple items
    Glados3(
      any.positiveDoubleOrZero,
      any.intInRange(1, 5),
      any.intInRange(1, 5),
    ).test(
      'Property 13: Cart total with multiple items is accurate',
      (price, qty1, qty2) {
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        final cartItems = [
          CartItem(
            id: 'item-1',
            product: product,
            quantity: qty1,
            selectedSize: 'S',
          ),
          CartItem(
            id: 'item-2',
            product: product,
            quantity: qty2,
            selectedSize: 'M',
          ),
        ];

        final cart = Cart(items: cartItems);

        // Calculate expected values
        final expectedSubtotal = cartItems.fold<double>(
          0.0,
          (sum, item) => sum + (item.product.displayPrice * item.quantity),
        );
        final expectedTax = expectedSubtotal * Cart.taxRate;
        final expectedTotal = expectedSubtotal + expectedTax;

        expect(cart.subtotal, closeTo(expectedSubtotal, 0.001));
        expect(cart.tax, closeTo(expectedTax, 0.001));
        expect(cart.total, closeTo(expectedTotal, 0.001));
      },
    );
  });

  group('Cart Service Properties', () {
    late CartService cartService;

    setUp(() {
      cartService = CartService();
    });

    // **Feature: union-shop-ecommerce, Property 8: Cart Addition Integrity**
    // **Validates: Requirements 14.1**
    Glados2(any.positiveDoubleOrZero, any.intInRange(1, 10)).test(
      'Property 8: Adding product to cart preserves options and increases item count',
      (price, quantity) {
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        const selectedSize = 'M';
        const selectedColour = 'Red';

        final initialCart = const Cart.empty();
        final initialItemCount = initialCart.itemCount;

        final updatedCart = cartService.add(
          initialCart,
          product,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColour: selectedColour,
        );

        // Verify cart contains an item with the exact options
        expect(updatedCart.items.length, equals(1));
        final addedItem = updatedCart.items.first;
        expect(addedItem.product.id, equals(product.id));
        expect(addedItem.quantity, equals(quantity));
        expect(addedItem.selectedSize, equals(selectedSize));
        expect(addedItem.selectedColour, equals(selectedColour));

        // Verify item count increased by the specified quantity
        expect(updatedCart.itemCount, equals(initialItemCount + quantity));
      },
    );

    // **Feature: union-shop-ecommerce, Property 8: Cart Addition Integrity (with custom text)**
    // **Validates: Requirements 14.1**
    Glados2(any.positiveDoubleOrZero, any.intInRange(1, 10)).test(
      'Property 8: Adding product with custom text preserves all options',
      (price, quantity) {
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        const customText = 'My Custom Text';

        final initialCart = const Cart.empty();

        final updatedCart = cartService.add(
          initialCart,
          product,
          quantity: quantity,
          selectedSize: 'L',
          selectedColour: 'Blue',
          customText: customText,
        );

        // Verify custom text is preserved
        final addedItem = updatedCart.items.first;
        expect(addedItem.customText, equals(customText));
      },
    );

    // **Feature: union-shop-ecommerce, Property 11: Cart Quantity Update Calculation**
    // **Validates: Requirements 18.1**
    Glados3(
      any.positiveDoubleOrZero,
      any.intInRange(1, 10),
      any.intInRange(1, 10),
    ).test(
      'Property 11: Updating quantity recalculates item total and cart total correctly',
      (price, initialQty, newQty) {
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        // Create cart with initial item
        final cartItem = CartItem(
          id: 'item-1',
          product: product,
          quantity: initialQty,
          selectedSize: 'M',
        );
        final initialCart = Cart(items: [cartItem]);

        // Update quantity
        final updatedCart = cartService.updateQuantity(
          initialCart,
          'item-1',
          newQty,
        );

        // Verify item total = price × new_quantity
        final updatedItem = updatedCart.items.first;
        final expectedItemTotal = product.displayPrice * newQty;
        expect(updatedItem.totalPrice, closeTo(expectedItemTotal, 0.001));

        // Verify cart total = sum of item totals + tax
        final expectedSubtotal = expectedItemTotal;
        final expectedTax = expectedSubtotal * Cart.taxRate;
        final expectedTotal = expectedSubtotal + expectedTax;

        expect(updatedCart.subtotal, closeTo(expectedSubtotal, 0.001));
        expect(updatedCart.tax, closeTo(expectedTax, 0.001));
        expect(updatedCart.total, closeTo(expectedTotal, 0.001));
      },
    );

    // **Feature: union-shop-ecommerce, Property 11: Cart Quantity Update with multiple items**
    // **Validates: Requirements 18.1**
    Glados(any.intInRange(1, 10)).test(
      'Property 11: Updating quantity in multi-item cart recalculates totals correctly',
      (newQty) {
        final product1 = createProduct(id: 'prod-1', price: 10.0);
        final product2 = createProduct(id: 'prod-2', price: 20.0);

        final cartItems = [
          CartItem(id: 'item-1', product: product1, quantity: 2),
          CartItem(id: 'item-2', product: product2, quantity: 3),
        ];
        final initialCart = Cart(items: cartItems);

        // Update quantity of first item
        final updatedCart = cartService.updateQuantity(
          initialCart,
          'item-1',
          newQty,
        );

        // Calculate expected totals
        final item1Total = product1.displayPrice * newQty;
        final item2Total = product2.displayPrice * 3;
        final expectedSubtotal = item1Total + item2Total;
        final expectedTax = expectedSubtotal * Cart.taxRate;
        final expectedTotal = expectedSubtotal + expectedTax;

        expect(updatedCart.subtotal, closeTo(expectedSubtotal, 0.001));
        expect(updatedCart.tax, closeTo(expectedTax, 0.001));
        expect(updatedCart.total, closeTo(expectedTotal, 0.001));
      },
    );

    // **Feature: union-shop-ecommerce, Property 12: Cart Removal Integrity**
    // **Validates: Requirements 18.2**
    Glados2(any.positiveDoubleOrZero, any.positiveDoubleOrZero).test(
      'Property 12: Removing item removes it from cart and recalculates totals',
      (price1, price2) {
        final validPrice1 = price1 > 0 ? price1 : 1.0;
        final validPrice2 = price2 > 0 ? price2 : 2.0;

        final product1 = createProduct(id: 'prod-1', price: validPrice1);
        final product2 = createProduct(id: 'prod-2', price: validPrice2);

        final cartItems = [
          CartItem(id: 'item-1', product: product1, quantity: 2),
          CartItem(id: 'item-2', product: product2, quantity: 1),
        ];
        final initialCart = Cart(items: cartItems);

        // Remove first item
        final updatedCart = cartService.remove(initialCart, 'item-1');

        // Verify item is no longer in cart
        expect(
          updatedCart.items.any((item) => item.id == 'item-1'),
          isFalse,
        );

        // Verify remaining item is still there
        expect(
          updatedCart.items.any((item) => item.id == 'item-2'),
          isTrue,
        );

        // Verify totals are recalculated without removed item
        final expectedSubtotal = product2.displayPrice * 1;
        final expectedTax = expectedSubtotal * Cart.taxRate;
        final expectedTotal = expectedSubtotal + expectedTax;

        expect(updatedCart.subtotal, closeTo(expectedSubtotal, 0.001));
        expect(updatedCart.tax, closeTo(expectedTax, 0.001));
        expect(updatedCart.total, closeTo(expectedTotal, 0.001));
      },
    );

    // **Feature: union-shop-ecommerce, Property 12: Cart Removal - removing last item**
    // **Validates: Requirements 18.2**
    Glados(any.positiveDoubleOrZero).test(
      'Property 12: Removing last item results in empty cart with zero totals',
      (price) {
        final validPrice = price > 0 ? price : 1.0;
        final product = createProduct(id: 'prod-1', price: validPrice);

        final cartItem = CartItem(
          id: 'item-1',
          product: product,
          quantity: 1,
        );
        final initialCart = Cart(items: [cartItem]);

        // Remove the only item
        final updatedCart = cartService.remove(initialCart, 'item-1');

        // Verify cart is empty
        expect(updatedCart.isEmpty, isTrue);
        expect(updatedCart.items.length, equals(0));

        // Verify totals are zero
        expect(updatedCart.subtotal, equals(0.0));
        expect(updatedCart.tax, equals(0.0));
        expect(updatedCart.total, equals(0.0));
      },
    );
  });
}
