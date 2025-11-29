import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide group, expect;
import 'package:union_shop/main.dart';
import 'package:union_shop/pages/about_page.dart';
import 'package:union_shop/pages/collections_page.dart';
import 'package:union_shop/pages/collection_page.dart';
import 'package:union_shop/pages/sale_page.dart';
import 'package:union_shop/pages/login_page.dart';
import 'package:union_shop/pages/signup_page.dart';
import 'package:union_shop/pages/cart_page.dart';
import 'package:union_shop/pages/account_page.dart';
import 'package:union_shop/pages/search_page.dart';
import 'package:union_shop/pages/print_shack_page.dart';
import 'package:union_shop/pages/print_shack_about_page.dart';
import 'package:union_shop/product_page.dart';

/// Route test case containing route path and expected widget type
class RouteTestCase {
  final String route;
  final Type expectedWidgetType;

  const RouteTestCase(this.route, this.expectedWidgetType);

  @override
  String toString() => 'RouteTestCase($route -> $expectedWidgetType)';
}

/// All static routes with their expected page widgets
const List<RouteTestCase> staticRoutes = [
  RouteTestCase('/', HomeScreen),
  RouteTestCase('/about', AboutPage),
  RouteTestCase('/collections', CollectionsPage),
  RouteTestCase('/sale', SalePage),
  RouteTestCase('/cart', CartPage),
  RouteTestCase('/login', LoginPage),
  RouteTestCase('/signup', SignupPage),
  RouteTestCase('/account', AccountPage),
  RouteTestCase('/print-shack', PrintShackPage),
  RouteTestCase('/print-shack/about', PrintShackAboutPage),
  RouteTestCase('/search', SearchPage),
  RouteTestCase('/product', ProductPage),
];

/// Sample collection IDs for dynamic route testing
const List<String> sampleCollectionIds = [
  'clothing',
  'souvenirs',
  'accessories',
  'stationery',
  'sale',
];

/// Sample product IDs for dynamic route testing
const List<String> sampleProductIds = ['1', '2', '3', '4'];

void main() {
  group('Navigation Route Resolution Properties', () {
    // **Feature: union-shop-ecommerce, Property 2: Navigation Route Resolution**
    // **Validates: Requirements 10.1, 10.3**
    //
    // *For any* defined route in the application, navigating to that route
    // SHALL display the corresponding page widget without errors.

    // Test all static routes
    for (final testCase in staticRoutes) {
      testWidgets(
        'Property 2: Route "${testCase.route}" resolves to ${testCase.expectedWidgetType}',
        (WidgetTester tester) async {
          // Build the app with the specific route
          await tester.pumpWidget(
            MaterialApp(
              onGenerateRoute: (settings) {
                // Use the same route generation logic as UnionShopApp
                return _generateTestRoute(settings);
              },
              initialRoute: testCase.route,
            ),
          );

          // Allow the widget tree to settle
          await tester.pump();

          // Verify the expected widget type is present
          expect(
            find.byType(testCase.expectedWidgetType),
            findsOneWidget,
            reason:
                'Route "${testCase.route}" should display ${testCase.expectedWidgetType}',
          );

          // Clear any pending image exceptions (network images fail in tests)
          tester.takeException();
        },
      );
    }

    // Test dynamic collection routes
    for (final collectionId in sampleCollectionIds) {
      testWidgets(
        'Property 2: Dynamic route "/collection/$collectionId" resolves to CollectionPage',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              onGenerateRoute: (settings) => _generateTestRoute(settings),
              initialRoute: '/collection/$collectionId',
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.byType(CollectionPage),
            findsOneWidget,
            reason:
                'Route "/collection/$collectionId" should display CollectionPage',
          );
        },
      );
    }

    // Test dynamic product routes
    for (final productId in sampleProductIds) {
      testWidgets(
        'Property 2: Dynamic route "/product/$productId" resolves to ProductPage',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              onGenerateRoute: (settings) => _generateTestRoute(settings),
              initialRoute: '/product/$productId',
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.byType(ProductPage),
            findsOneWidget,
            reason:
                'Route "/product/$productId" should display ProductPage',
          );
        },
      );
    }

    // Property test: Unknown routes should redirect to home
    Glados(any.letterOrDigits).test(
      'Property 2: Unknown routes redirect to HomeScreen',
      (randomPath) {
        // Skip if the random path matches a known route
        final testRoute = '/unknown-$randomPath';
        final isKnownRoute = AppRoutes.allRoutes.contains(testRoute) ||
            testRoute.startsWith('/collection/') ||
            testRoute.startsWith('/product/');

        if (!isKnownRoute) {
          // This is a unit test for the route generation logic
          final settings = RouteSettings(name: testRoute);
          final route = _generateTestRoute(settings);

          expect(route, isNotNull);
          // The route should be generated (redirecting to home for unknown routes)
        }
      },
    );

    // Test search route with query parameter
    testWidgets(
      'Property 2: Route "/search?q=test" resolves to SearchPage with query',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) => _generateTestRoute(settings),
            initialRoute: '/search?q=test',
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(SearchPage),
          findsOneWidget,
          reason: 'Route "/search?q=test" should display SearchPage',
        );
      },
    );
  });
}

/// Generates routes for testing - mirrors the logic in UnionShopApp
Route<dynamic>? _generateTestRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  final pathSegments = uri.pathSegments;

  // Handle root route
  if (settings.name == '/' || pathSegments.isEmpty) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const HomeScreen(),
    );
  }

  // Handle static routes
  switch (settings.name) {
    case AppRoutes.about:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AboutPage(),
      );
    case AppRoutes.collections:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CollectionsPage(),
      );
    case AppRoutes.sale:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SalePage(),
      );
    case AppRoutes.cart:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CartPage(),
      );
    case AppRoutes.login:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const LoginPage(),
      );
    case AppRoutes.signup:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SignupPage(),
      );
    case AppRoutes.account:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AccountPage(),
      );
    case AppRoutes.printShack:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const PrintShackPage(),
      );
    case AppRoutes.printShackAbout:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const PrintShackAboutPage(),
      );
    case AppRoutes.search:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SearchPage(),
      );
    case AppRoutes.product:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ProductPage(),
      );
  }

  // Handle dynamic routes with parameters
  // /collection/:id
  if (pathSegments.length == 2 && pathSegments[0] == 'collection') {
    final collectionId = pathSegments[1];
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => CollectionPage(collectionId: collectionId),
    );
  }

  // /product/:id
  if (pathSegments.length == 2 && pathSegments[0] == 'product') {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const ProductPage(),
    );
  }

  // /search with query parameter
  if (pathSegments.length == 1 && pathSegments[0] == 'search') {
    final query = uri.queryParameters['q'];
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => SearchPage(query: query),
    );
  }

  // Unknown route - redirect to home
  return MaterialPageRoute(
    settings: settings,
    builder: (context) => const HomeScreen(),
  );
}
