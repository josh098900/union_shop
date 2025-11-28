import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/widgets/navbar.dart';

void main() {
  group('Navbar Widget Tests', () {
    // Helper to create a test widget with proper scaffold and navigation context
    Widget createTestWidget({
      double width = 400, // Mobile by default
      bool withDrawer = true,
    }) {
      return MaterialApp(
        routes: {
          '/collections': (context) => const Scaffold(body: Text('Collections')),
          '/about': (context) => const Scaffold(body: Text('About')),
          '/cart': (context) => const Scaffold(body: Text('Cart')),
          '/account': (context) => const Scaffold(body: Text('Account')),
        },
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Builder(
            builder: (context) => Scaffold(
              endDrawer: withDrawer ? const NavbarDrawer() : null,
              body: const Column(
                children: [
                  Navbar(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    group('Logo Navigation (Req 2.1)', () {
      testWidgets('should display logo image', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Logo is rendered as an Image.network widget
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('logo should be tappable via GestureDetector', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Find the GestureDetector wrapping the logo (ancestor of Image)
        final logoImage = find.byType(Image);
        expect(logoImage, findsOneWidget);
        
        // Verify the logo has a GestureDetector ancestor
        expect(
          find.ancestor(of: logoImage, matching: find.byType(GestureDetector)),
          findsWidgets,
        );
      });
    });

    group('Icon Presence (Req 2.2)', () {
      testWidgets('should display search icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should display account icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });

      testWidgets('should display cart icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });

      testWidgets('should display menu icon on mobile viewport', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        expect(find.byIcon(Icons.menu), findsOneWidget);
      });
    });

    group('Drawer Opening (Req 2.3)', () {
      testWidgets('tapping menu icon should open drawer on mobile', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        // Verify drawer is not visible initially
        expect(find.byType(Drawer), findsNothing);

        // Tap the menu icon
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        // Verify drawer is now visible
        expect(find.byType(Drawer), findsOneWidget);
      });

      testWidgets('drawer should contain navigation menu items', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        // Open the drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        // Check menu items are present
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Collections'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Cart'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
      });
    });

    group('Desktop Viewport (Req 2.5)', () {
      testWidgets('should show inline navigation links on desktop', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 800));
        await tester.pump();

        // Desktop should show inline navigation links
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Collections'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
      });

      testWidgets('should not show menu icon on desktop', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 800));
        await tester.pump();

        // Menu icon should not be visible on desktop
        expect(find.byIcon(Icons.menu), findsNothing);
      });

      testWidgets('should still show utility icons on desktop', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 800));
        await tester.pump();

        // Utility icons should still be present
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.person_outline), findsOneWidget);
        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });
    });
  });
}
