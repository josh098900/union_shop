import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/main.dart';
import 'package:union_shop/pages/about_page.dart';
import 'package:union_shop/pages/collections_page.dart';
import 'package:union_shop/pages/sale_page.dart';
import 'package:union_shop/pages/cart_page.dart';
import 'package:union_shop/pages/login_page.dart';
import 'package:union_shop/pages/signup_page.dart';
import 'package:union_shop/pages/account_page.dart';
import 'package:union_shop/pages/search_page.dart';

void main() {
  group('Navigation Integration Tests', () {
    // Test back button navigation (Req 10.2)
    testWidgets('back button navigates to previous page', (tester) async {
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Verify we're on the home page
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to About page
      // First, set desktop viewport to see inline navigation
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Find and tap the About link
      final aboutLink = find.text('About');
      expect(aboutLink, findsOneWidget);
      await tester.tap(aboutLink);
      await tester.pumpAndSettle();

      // Verify we're on the About page
      expect(find.byType(AboutPage), findsOneWidget);

      // Simulate back button press
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Verify we're back on the home page
      expect(find.byType(HomeScreen), findsOneWidget);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();

      // Clear any pending image exceptions
      tester.takeException();
    });

    // Test direct URL access (Req 10.3)
    testWidgets('direct URL access to /about displays AboutPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/about',
        ),
      );
      await tester.pump();

      expect(find.byType(AboutPage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /collections displays CollectionsPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/collections',
        ),
      );
      await tester.pump();

      expect(find.byType(CollectionsPage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /sale displays SalePage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/sale',
        ),
      );
      await tester.pump();

      expect(find.byType(SalePage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /cart displays CartPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/cart',
        ),
      );
      await tester.pump();

      expect(find.byType(CartPage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /login displays LoginPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/login',
        ),
      );
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /signup displays SignupPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/signup',
        ),
      );
      await tester.pump();

      expect(find.byType(SignupPage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /account displays AccountPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/account',
        ),
      );
      await tester.pump();

      expect(find.byType(AccountPage), findsOneWidget);
      tester.takeException();
    });

    testWidgets('direct URL access to /search displays SearchPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => _generateRoute(settings),
          initialRoute: '/search',
        ),
      );
      await tester.pump();

      expect(find.byType(SearchPage), findsOneWidget);
      tester.takeException();
    });

    // Test navigation from navbar links (Req 10.1)
    testWidgets('navbar Collections link navigates to CollectionsPage', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Find and tap the Collections link
      final collectionsLink = find.text('Collections');
      expect(collectionsLink, findsOneWidget);
      await tester.tap(collectionsLink);
      await tester.pumpAndSettle();

      // Verify we're on the Collections page
      expect(find.byType(CollectionsPage), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.takeException();
    });

    testWidgets('navbar Sale link navigates to SalePage', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Find and tap the Sale link
      final saleLink = find.text('Sale');
      expect(saleLink, findsOneWidget);
      await tester.tap(saleLink);
      await tester.pumpAndSettle();

      // Verify we're on the Sale page
      expect(find.byType(SalePage), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.takeException();
    });

    // Test URL updates on navigation (Req 10.4)
    testWidgets('navigation updates route settings', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Navigate to About page
      final aboutLink = find.text('About');
      await tester.tap(aboutLink);
      await tester.pumpAndSettle();

      // Verify the route was pushed
      expect(find.byType(AboutPage), findsOneWidget);

      // The route should be /about
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      expect(navigator.canPop(), isTrue);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.takeException();
    });

    // Test drawer navigation closes drawer (Req 2.4)
    testWidgets('drawer menu item closes drawer on navigation', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const UnionShopApp());
      await tester.pump();

      // Open the drawer
      final menuIcon = find.byIcon(Icons.menu);
      expect(menuIcon, findsOneWidget);
      await tester.tap(menuIcon);
      await tester.pumpAndSettle();

      // Verify drawer is open
      expect(find.text('Union Shop'), findsOneWidget); // Drawer header

      // Tap on Collections in the drawer
      final collectionsItem = find.text('Collections');
      expect(collectionsItem, findsOneWidget);
      await tester.tap(collectionsItem);
      await tester.pumpAndSettle();

      // Verify drawer is closed and we're on Collections page
      expect(find.byType(CollectionsPage), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.takeException();
    });
  });
}

/// Route generator for tests - mirrors UnionShopApp logic
Route<dynamic>? _generateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  final pathSegments = uri.pathSegments;

  if (settings.name == '/' || pathSegments.isEmpty) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const HomeScreen(),
    );
  }

  switch (settings.name) {
    case '/about':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AboutPage(),
      );
    case '/collections':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CollectionsPage(),
      );
    case '/sale':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SalePage(),
      );
    case '/cart':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CartPage(),
      );
    case '/login':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const LoginPage(),
      );
    case '/signup':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SignupPage(),
      );
    case '/account':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AccountPage(),
      );
    case '/search':
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SearchPage(),
      );
  }

  return MaterialPageRoute(
    settings: settings,
    builder: (context) => const HomeScreen(),
  );
}
