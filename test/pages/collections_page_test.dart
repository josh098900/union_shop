import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/pages/collections_page.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/collection_card.dart';

void main() {
  group('CollectionsPage Widget Tests', () {
    // Helper to create a test widget with proper context
    Widget createTestWidget({double width = 400}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: const CollectionsPage(),
        ),
        onGenerateRoute: (settings) {
          // Handle navigation routes for testing
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
            case '/collections':
              return MaterialPageRoute(builder: (_) => const CollectionsPage());
            case '/about':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('About')));
            case '/cart':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Cart')));
            case '/account':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Account')));
            default:
              // Handle collection/:id routes
              if (settings.name?.startsWith('/collection/') ?? false) {
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Collection')));
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

      testWidgets('should display Collections heading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Collections'), findsOneWidget);
      });
    });

    group('Collection Cards (Req 5.1)', () {
      testWidgets('should display at least 4 collection cards', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Req 5.1: Display at least 4 collection cards
        final collectionCards = find.byType(CollectionCard);
        expect(collectionCards, findsAtLeast(4));
      });

      testWidgets('should display collection titles', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for expected collection titles
        expect(find.text('Clothing'), findsOneWidget);
        expect(find.text('Souvenirs'), findsOneWidget);
        expect(find.text('Accessories'), findsOneWidget);
        expect(find.text('Stationery'), findsOneWidget);
      });
    });

    group('Responsive Grid Layout (Req 5.4)', () {
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
