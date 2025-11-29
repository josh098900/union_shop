import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/main.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';

void main() {
  group('Home Page Tests', () {
    testWidgets('should display hero section with title, description, and CTA button (Req 1.1)',
        (tester) async {
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Check hero section elements (Req 1.1)
      expect(find.text('Welcome to Union Shop'), findsOneWidget);
      expect(
        find.text(
            'Your one-stop shop for University of Portsmouth merchandise and souvenirs.'),
        findsOneWidget,
      );
      expect(find.text('BROWSE PRODUCTS'), findsOneWidget);
      
      // Clear any pending image exceptions
      tester.takeException();
    });

    testWidgets('should display at least 4 product cards (Req 1.2)', (tester) async {
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Check that at least 4 ProductCard widgets are displayed (Req 1.2)
      expect(find.byType(ProductCard), findsNWidgets(4));

      // Check product titles
      expect(find.text('Portsmouth City Magnet'), findsOneWidget);
      expect(find.text('University Hoodie'), findsOneWidget);
      expect(find.text('Portsmouth Postcard Set'), findsOneWidget);
      expect(find.text('Union Shop Tote Bag'), findsOneWidget);
      
      // Clear any pending image exceptions
      tester.takeException();
    });

    testWidgets('should display Navbar with header elements (Req 1.3)', (tester) async {
      // Set a mobile viewport to ensure menu icon is visible
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Check that Navbar widget is present (Req 1.3)
      expect(find.byType(Navbar), findsOneWidget);

      // Check header banner text
      expect(find.text('PLACEHOLDER HEADER TEXT'), findsOneWidget);

      // Check header icons are present (search, account, cart, menu)
      // Note: search icon appears in both navbar and footer, so we check for at least one
      expect(find.byIcon(Icons.search), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      
      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      
      // Clear any pending image exceptions
      tester.takeException();
    });

    testWidgets('should display Footer widget (Req 4.1, 4.2, 4.3)', (tester) async {
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Check that Footer widget is present
      expect(find.byType(Footer), findsOneWidget);

      // Check footer sections are present (Req 4.1, 4.2, 4.3)
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('Follow Us'), findsOneWidget);
      expect(find.text('Policies'), findsOneWidget);
      
      // Clear any pending image exceptions
      tester.takeException();
    });

    testWidgets('should display single-column layout on mobile viewport (Req 1.4)',
        (tester) async {
      // Set mobile viewport size (< 600px)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Find the GridView and check its cross axis count
      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      final gridView = tester.widget<GridView>(gridViewFinder);
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      
      // Mobile should have single column (Req 1.4)
      expect(delegate.crossAxisCount, equals(1));

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      
      // Clear any pending image exceptions
      tester.takeException();
    });

    testWidgets('should display multi-column layout on desktop viewport (Req 1.5)',
        (tester) async {
      // Set desktop viewport size (>= 1024px)
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Find the GridView and check its cross axis count
      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      final gridView = tester.widget<GridView>(gridViewFinder);
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      
      // Desktop (>1024px) should have 4 columns (Req 1.5, 16.3)
      expect(delegate.crossAxisCount, equals(4));

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      
      // Clear any pending image exceptions
      tester.takeException();
    });

    testWidgets('should display products section title', (tester) async {
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Check products section title
      expect(find.text('FEATURED PRODUCTS'), findsOneWidget);
      
      // Clear any pending image exceptions
      tester.takeException();
    });
  });
}
