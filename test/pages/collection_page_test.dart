import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/pages/collection_page.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';
import 'package:union_shop/widgets/filter_dropdown.dart';
import 'package:union_shop/widgets/sort_dropdown.dart';

void main() {
  group('CollectionPage Widget Tests', () {
    // Helper to create a test widget with proper context
    Widget createTestWidget({double width = 400, String collectionId = 'clothing'}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: CollectionPage(collectionId: collectionId),
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

    group('Page Structure (Req 6.1)', () {
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


      testWidgets('should display collection title', (tester) async {
        await tester.pumpWidget(createTestWidget(collectionId: 'clothing'));
        await tester.pump();

        // Req 6.1: Display collection title
        expect(find.text('Clothing'), findsOneWidget);
      });

      testWidgets('should display different title for different collection', (tester) async {
        await tester.pumpWidget(createTestWidget(collectionId: 'accessories'));
        await tester.pump();

        expect(find.text('Accessories'), findsOneWidget);
      });
    });

    group('Filter Dropdowns (Req 6.2)', () {
      testWidgets('should display filter dropdowns', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 6.2: Display filter dropdowns for size and colour attributes
        final filterDropdowns = find.byType(FilterDropdown);
        expect(filterDropdowns, findsAtLeast(2)); // Size, Colour
      });

      testWidgets('should display Size filter label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Size'), findsOneWidget);
      });

      testWidgets('should display Colour filter label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Colour'), findsOneWidget);
      });
    });

    group('Sort Dropdown (Req 6.3)', () {
      testWidgets('should display sort dropdown', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 6.3: Display sort dropdown
        expect(find.byType(SortDropdown), findsOneWidget);
      });

      testWidgets('should display Sort by label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Sort by'), findsOneWidget);
      });
    });

    group('Product Grid (Req 6.4, 6.5)', () {
      testWidgets('should display product cards', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 6.4: Display ProductCard widgets
        final productCards = find.byType(ProductCard);
        expect(productCards, findsAtLeast(1));
      });

      testWidgets('should display single column on mobile (Req 6.5)', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        // On mobile, grid should have 1 column
        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(1));
      });

      testWidgets('should display 2 columns on tablet (Req 6.5)', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 700));
        await tester.pump();

        // On tablet, grid should have 2 columns
        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(2));
      });

      testWidgets('should display 3 columns on desktop (Req 6.5)', (tester) async {
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
