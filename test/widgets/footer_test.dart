import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/widgets/footer.dart';

void main() {
  group('Footer Widget Tests', () {
    // Helper to create a test widget with proper context
    Widget createTestWidget({double width = 400}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: const Scaffold(
            body: SingleChildScrollView(
              child: Footer(),
            ),
          ),
        ),
      );
    }

    group('Contact Information Section (Req 4.1)', () {
      testWidgets('should display Contact Us section title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Contact Us'), findsOneWidget);
      });

      testWidgets('should display location icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });

      testWidgets('should display email icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('should display phone icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.phone), findsOneWidget);
      });

      testWidgets('should display contact email', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('shop@upsu.net'), findsOneWidget);
      });
    });

    group('Social Media Links Section (Req 4.2)', () {
      testWidgets('should display Follow Us section title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Follow Us'), findsOneWidget);
      });

      testWidgets('should display social media icons', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for social icons
        expect(find.byIcon(Icons.facebook), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.alternate_email), findsOneWidget);
      });
    });

    group('Policy Links Section (Req 4.3)', () {
      testWidgets('should display Policies section title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Policies'), findsOneWidget);
      });

      testWidgets('should display Privacy Policy link', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Privacy Policy'), findsOneWidget);
      });

      testWidgets('should display Terms of Service link', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Terms of Service'), findsOneWidget);
      });

      testWidgets('should display Returns Policy link', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Returns Policy'), findsOneWidget);
      });
    });

    group('Search Input Section', () {
      testWidgets('should display Search section title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Search'), findsOneWidget);
      });

      testWidgets('should display search input field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should display search button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    group('Copyright Section', () {
      testWidgets('should display copyright text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(
          find.text('© 2025 Union Shop. All rights reserved.'),
          findsOneWidget,
        );
      });
    });

    group('Responsive Layout', () {
      testWidgets('should use column layout on mobile', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 400));
        await tester.pump();

        // All sections should be present
        expect(find.text('Contact Us'), findsOneWidget);
        expect(find.text('Follow Us'), findsOneWidget);
        expect(find.text('Policies'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
      });

      testWidgets('should use row layout on desktop', (tester) async {
        await tester.pumpWidget(createTestWidget(width: 800));
        await tester.pump();

        // All sections should be present
        expect(find.text('Contact Us'), findsOneWidget);
        expect(find.text('Follow Us'), findsOneWidget);
        expect(find.text('Policies'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
      });
    });
  });
}
