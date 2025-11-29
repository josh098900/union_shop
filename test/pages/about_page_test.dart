import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/pages/about_page.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';

void main() {
  group('AboutPage Widget Tests', () {
    // Helper to create a test widget with proper context
    Widget createTestWidget({double width = 400}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: const AboutPage(),
        ),
        onGenerateRoute: (settings) {
          // Handle navigation routes for testing
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
            case '/collections':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Collections')));
            case '/about':
              return MaterialPageRoute(builder: (_) => const AboutPage());
            case '/cart':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Cart')));
            case '/account':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Account')));
            default:
              return null;
          }
        },
      );
    }

    group('Page Structure (Req 3.1)', () {
      testWidgets('should display a page distinct from homepage', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // About page should have its own hero section with "About Us" title
        expect(find.text('About Us'), findsOneWidget);
      });

      testWidgets('should include Navbar component (Req 3.4)', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Navbar), findsOneWidget);
      });

      testWidgets('should include Footer component (Req 3.4)', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Footer), findsOneWidget);
      });
    });

    group('Structured Content (Req 3.2)', () {
      testWidgets('should display About Us heading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('About Us'), findsOneWidget);
      });

      testWidgets('should display Our Mission heading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Our Mission'), findsOneWidget);
      });

      testWidgets('should display Our Values heading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Our Values'), findsOneWidget);
      });

      testWidgets('should display descriptive text about the organisation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for key descriptive text
        expect(
          find.textContaining('University of Portsmouth Students'),
          findsWidgets,
        );
      });

      testWidgets('should display value cards with titles', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Community'), findsOneWidget);
        expect(find.text('Sustainability'), findsOneWidget);
        expect(find.text('Quality'), findsOneWidget);
      });
    });

    group('Brand Image/Icon (Req 3.3)', () {
      testWidgets('should display brand image or icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for the brand image (network image) or fallback icon
        final imageFinder = find.byType(Image);
        final iconFinder = find.byIcon(Icons.store);
        
        // Either the image loads or the fallback icon is shown
        expect(
          imageFinder.evaluate().isNotEmpty || iconFinder.evaluate().isNotEmpty,
          isTrue,
        );
      });

      testWidgets('should display value icons', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.people), findsOneWidget);
        expect(find.byIcon(Icons.eco), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });
    });

    group('Responsive Layout', () {
      testWidgets('should display all sections on mobile', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        expect(find.text('About Us'), findsOneWidget);
        expect(find.text('Our Mission'), findsOneWidget);
        expect(find.text('Our Values'), findsOneWidget);
      });

      testWidgets('should display all sections on desktop', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 1024));
        await tester.pump();

        expect(find.text('About Us'), findsOneWidget);
        expect(find.text('Our Mission'), findsOneWidget);
        expect(find.text('Our Values'), findsOneWidget);
      });
    });
  });
}
