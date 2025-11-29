import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:union_shop/product_page.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/providers/cart_provider.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/quantity_selector.dart';

void main() {
  group('ProductPage Widget Tests', () {
    Widget createTestWidget({Product? product}) {
      return ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: MaterialApp(
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
              case '/cart':
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Cart')));
              case '/collections':
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Collections')));
              case '/about':
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('About')));
              case '/account':
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Account')));
              default:
                return MaterialPageRoute(builder: (_) => ProductPage(product: product));
            }
          },
          home: ProductPage(product: product),
        ),
      );
    }

    // Test product with all options
    final testProduct = Product(
      id: 'test-1',
      title: 'Test Product',
      description: 'Test product description for testing purposes.',
      price: 25.00,
      imageUrls: ['https://example.com/image.jpg'],
      sizes: ['S', 'M', 'L'],
      colours: ['Red', 'Blue', 'Green'],
      collectionId: 'collection-1',
      createdAt: DateTime(2024, 1, 1),
    );

    // Req 7.1: Product image, title, price, and description
    testWidgets('displays product image, title, price, and description (Req 7.1)', (tester) async {
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Test Product'), findsOneWidget);
      
      // Price
      expect(find.text('£25.00'), findsOneWidget);
      
      // Description section
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Test product description for testing purposes.'), findsOneWidget);
    });

    // Req 7.2: Size and colour dropdowns
    testWidgets('displays size and colour dropdowns (Req 7.2)', (tester) async {
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      // Size dropdown label
      expect(find.text('Size'), findsOneWidget);
      
      // Colour dropdown label
      expect(find.text('Colour'), findsOneWidget);
    });

    // Req 7.3: Quantity selector widget
    testWidgets('displays quantity selector widget (Req 7.3)', (tester) async {
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      // Quantity label
      expect(find.text('Quantity'), findsOneWidget);
      
      // QuantitySelector widget
      expect(find.byType(QuantitySelector), findsOneWidget);
      
      // Initial quantity value
      expect(find.text('1'), findsOneWidget);
      
      // Increment/decrement buttons
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    // Req 7.4: Add to Cart button
    testWidgets('displays Add to Cart button (Req 7.4)', (tester) async {
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    // Req 7.5: Shared navbar and footer components
    testWidgets('includes shared navbar and footer components (Req 7.5)', (tester) async {
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      // Navbar widget
      expect(find.byType(Navbar), findsOneWidget);
      
      // Footer widget
      expect(find.byType(Footer), findsOneWidget);
      
      // Navbar elements
      expect(find.text('PLACEHOLDER HEADER TEXT'), findsOneWidget);
      // Search icon appears in both navbar and footer
      expect(find.byIcon(Icons.search), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      
      // Footer elements
      expect(find.text('Contact Us'), findsOneWidget);
    });

    // Test placeholder product when no product is provided
    testWidgets('displays placeholder product when no product provided', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When no product ID or product is provided, shows "Product Not Found"
      expect(find.text('Product Not Found'), findsOneWidget);
      expect(find.text('£0.00'), findsOneWidget);
    });

    // Test Add to Cart button shows snackbar feedback (Req 13.4, 14.1)
    testWidgets('Add to Cart button shows visual feedback', (tester) async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      // Scroll to make Add to Cart button visible
      await tester.scrollUntilVisible(
        find.text('Add to Cart'),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap Add to Cart button
      await tester.tap(find.text('Add to Cart'));
      // Pump multiple frames to allow async addToCart to complete and snackbar to appear
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Snackbar should appear with confirmation message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Added'), findsOneWidget);
      expect(find.textContaining('Test Product'), findsAtLeastNWidgets(1));
    });

    // Test quantity selector interaction
    testWidgets('quantity selector can increment and decrement', (tester) async {
      await tester.pumpWidget(createTestWidget(product: testProduct));
      await tester.pumpAndSettle();

      // Scroll to make quantity selector visible
      await tester.scrollUntilVisible(
        find.byType(QuantitySelector),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Initial quantity is 1
      expect(find.text('1'), findsOneWidget);

      // Tap increment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Tap decrement
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });
  });
}
