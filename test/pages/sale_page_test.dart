import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/pages/sale_page.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';

void main() {
  group('SalePage Widget Tests', () {
    // Helper to create a test widget with proper context
    Widget createTestWidget({double width = 400}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: const SalePage(),
        ),
        onGenerateRoute: (settings) {
          // Handle navigation routes for testing
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
            case '/collections':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Collections')));
            case '/about':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('About')));
            case '/cart':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Cart')));
            case '/account':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Account')));
            default:
              // Handle product/:id routes
              if (settings.name?.startsWith('/product/') ?? false) {
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Product')));
              }
              return null;
          }
        },
      );
    }

    group('Page Structure', () {
      testWidgets('should include Navbar component', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Navbar), findsOneWidget);
      });

      testWidgets('should include Footer component', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Footer), findsOneWidget);
      });
    });


    group('Promotional Banner (Req 8.1, 8.3)', () {
      testWidgets('should display SALE title in banner', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 8.1: Display promotional banner
        expect(find.text('SALE'), findsOneWidget);
      });

      testWidgets('should display promotional label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 8.3: Display promotional labels indicating sale status
        expect(find.text('🔥 LIMITED TIME OFFER'), findsOneWidget);
      });

      testWidgets('should display discount information', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 8.3: Display promotional information
        expect(find.text('Up to 35% off selected items'), findsOneWidget);
      });

      testWidgets('should display call to action text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Don\'t miss out on these amazing deals!'), findsOneWidget);
      });
    });

    group('Sale Products Display (Req 8.2, 8.4)', () {
      testWidgets('should display sale items section header', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Sale Items'), findsOneWidget);
      });

      testWidgets('should display product cards', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 8.2: Display products with discounted prices
        final productCards = find.byType(ProductCard);
        expect(productCards, findsAtLeast(1));
      });

      testWidgets('should display at least 6 sale products', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify we have the expected number of sale products
        final productCards = find.byType(ProductCard);
        expect(productCards, findsNWidgets(6));
      });
    });

    group('Responsive Layout', () {
      testWidgets('should display single column on mobile', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        // On mobile, grid should have 1 column
        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(1));
      });

      testWidgets('should display 2 columns on tablet', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 700));
        await tester.pump();

        // On tablet, grid should have 2 columns
        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(2));
      });

      testWidgets('should display 3 columns on desktop', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 1024));
        await tester.pump();

        // On desktop, grid should have 3 columns
        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(3));
      });
    });
  });
}
