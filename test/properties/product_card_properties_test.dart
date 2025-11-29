import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/widgets/product_card.dart';

/// Helper class to hold price pairs for testing
class PricePair {
  final double originalPrice;
  final double salePrice;
  
  PricePair(this.originalPrice, this.salePrice);
}

/// Helper to create a product with given price and optional sale price
Product createProduct({
  required String id,
  required double price,
  double? salePrice,
  String title = 'Test Product',
}) {
  return Product(
    id: id,
    title: title,
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

/// Generates random price pairs for property testing
/// Returns list of PricePair where salePrice < originalPrice
List<PricePair> generateSalePricePairs(int count, {int seed = 42}) {
  final random = Random(seed);
  final pairs = <PricePair>[];
  
  for (int i = 0; i < count; i++) {
    // Generate original price between 5.0 and 500.0
    final originalPrice = 5.0 + random.nextDouble() * 495.0;
    // Generate sale price between 0.01 and originalPrice - 0.01
    final salePrice = 0.01 + random.nextDouble() * (originalPrice - 0.02);
    pairs.add(PricePair(originalPrice, salePrice));
  }
  
  return pairs;
}

/// Generates random prices for non-sale products
List<double> generateRegularPrices(int count, {int seed = 42}) {
  final random = Random(seed);
  return List.generate(count, (_) => 5.0 + random.nextDouble() * 495.0);
}

void main() {
  group('ProductCard Properties', () {
    // **Feature: union-shop-ecommerce, Property 1: Sale Product Display Format**
    // **Validates: Requirements 8.2, 8.4**
    //
    // For any product with a sale price, when rendered as a ProductCard with
    // showSaleBadge: true, the widget SHALL display both the original price
    // (with strikethrough styling) and the sale price, plus a visible sale badge.

    final salePricePairs = generateSalePricePairs(100);

    testWidgets(
      'Property 1: Sale product displays original price, sale price, and badge',
      (WidgetTester tester) async {
        // Test with 100 generated price combinations
        for (final pair in salePricePairs) {
          final originalPrice = pair.originalPrice;
          final salePrice = pair.salePrice;
          
          final product = createProduct(
            id: 'test-product',
            price: originalPrice,
            salePrice: salePrice,
          );

          // Verify the product is actually on sale
          expect(product.isOnSale, isTrue,
              reason: 'Product should be on sale when salePrice ($salePrice) < price ($originalPrice)');

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ProductCard(
                    product: product,
                    showSaleBadge: true,
                  ),
                ),
              ),
            ),
          );

          // Verify sale badge is displayed (Req 8.4)
          expect(find.text('Sale'), findsOneWidget,
              reason: 'Sale badge should be visible for sale products');

          // Verify original price with strikethrough is displayed (Req 8.2)
          final originalPriceText = '£${originalPrice.toStringAsFixed(2)}';
          expect(find.text(originalPriceText), findsOneWidget,
              reason: 'Original price should be displayed');

          // Verify sale price is displayed (Req 8.2)
          final salePriceText = '£${salePrice.toStringAsFixed(2)}';
          expect(find.text(salePriceText), findsOneWidget,
              reason: 'Sale price should be displayed');

          // Verify the original price has strikethrough decoration
          final originalPriceFinder = find.text(originalPriceText);
          final originalPriceWidget = tester.widget<Text>(originalPriceFinder);
          expect(
            originalPriceWidget.style?.decoration,
            equals(TextDecoration.lineThrough),
            reason: 'Original price should have strikethrough decoration',
          );
        }
      },
    );

    final regularPrices = generateRegularPrices(100);

    testWidgets(
      'Property 1 (inverse): Non-sale product does not display sale badge',
      (WidgetTester tester) async {
        // Test with 100 generated prices
        for (final price in regularPrices) {
          // Create product without sale price
          final product = createProduct(
            id: 'test-product',
            price: price,
            salePrice: null,
          );

          // Verify the product is not on sale
          expect(product.isOnSale, isFalse,
              reason: 'Product should not be on sale without salePrice');

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ProductCard(
                    product: product,
                    showSaleBadge: true,
                  ),
                ),
              ),
            ),
          );

          // Verify sale badge is NOT displayed
          expect(find.text('Sale'), findsNothing,
              reason: 'Sale badge should not be visible for non-sale products');

          // Verify only regular price is displayed
          final priceText = '£${price.toStringAsFixed(2)}';
          expect(find.text(priceText), findsOneWidget,
              reason: 'Regular price should be displayed');
        }
      },
    );

    testWidgets(
      'Property 1 (variant): showSaleBadge=false hides sale badge',
      (WidgetTester tester) async {
        // Test with 100 generated price combinations
        for (final pair in salePricePairs) {
          final originalPrice = pair.originalPrice;
          final salePrice = pair.salePrice;
          
          final product = createProduct(
            id: 'test-product',
            price: originalPrice,
            salePrice: salePrice,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ProductCard(
                    product: product,
                    showSaleBadge: false,
                  ),
                ),
              ),
            ),
          );

          // Verify sale badge is NOT displayed when showSaleBadge is false
          expect(find.text('Sale'), findsNothing,
              reason: 'Sale badge should not be visible when showSaleBadge is false');

          // Verify only regular display price is shown (not strikethrough)
          final displayPriceText = '£${product.displayPrice.toStringAsFixed(2)}';
          expect(find.text(displayPriceText), findsOneWidget,
              reason: 'Display price should be shown');
        }
      },
    );
  });
}
