import 'package:test/test.dart';
import 'package:glados/glados.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/models/cart_item.dart';
import 'package:union_shop/models/cart.dart';

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
}
