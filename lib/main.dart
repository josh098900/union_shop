import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/product_page.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';
import 'package:union_shop/pages/collections_page.dart';
import 'package:union_shop/pages/collection_page.dart';
import 'package:union_shop/pages/about_page.dart';
import 'package:union_shop/pages/sale_page.dart';
import 'package:union_shop/pages/login_page.dart';
import 'package:union_shop/pages/signup_page.dart';
import 'package:union_shop/pages/cart_page.dart';
import 'package:union_shop/pages/account_page.dart';
import 'package:union_shop/pages/search_page.dart';
import 'package:union_shop/pages/print_shack_page.dart';
import 'package:union_shop/pages/print_shack_about_page.dart';
import 'package:union_shop/providers/cart_provider.dart';
import 'package:union_shop/providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()..loadCart()),
        ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
      ],
      child: const UnionShopApp(),
    ),
  );
}

/// Route names for the application.
/// 
/// Requirements: 10.1, 10.3, 10.4
class AppRoutes {
  static const String home = '/';
  static const String about = '/about';
  static const String collections = '/collections';
  static const String collection = '/collection'; // /collection/:id
  static const String product = '/product'; // /product/:id
  static const String sale = '/sale';
  static const String cart = '/cart';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String account = '/account';
  static const String printShack = '/print-shack';
  static const String printShackAbout = '/print-shack/about';
  static const String search = '/search';

  /// List of all defined routes for testing
  static const List<String> allRoutes = [
    home,
    about,
    collections,
    sale,
    cart,
    login,
    signup,
    account,
    printShack,
    printShackAbout,
    search,
  ];

  /// Dynamic routes that require parameters
  static const List<String> dynamicRoutes = [
    collection, // requires :id
    product, // requires :id
  ];
}

class UnionShopApp extends StatelessWidget {
  const UnionShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Union Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4d2963)),
      ),
      // Use onGenerateRoute for dynamic route handling (Req 10.1, 10.3, 10.4)
      onGenerateRoute: _generateRoute,
      initialRoute: AppRoutes.home,
    );
  }

  /// Generates routes with support for dynamic parameters.
  /// 
  /// Handles routes like /collection/:id and /product/:id
  /// Requirements: 10.1, 10.3, 10.4
  Route<dynamic>? _generateRoute(RouteSettings settings) {
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
      // Legacy /product route without ID
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

    // /product/:id - Load product from service by ID (Req 13.1)
    if (pathSegments.length == 2 && pathSegments[0] == 'product') {
      final productId = pathSegments[1];
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ProductPage(productId: productId),
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

    // Unknown route - redirect to home (Req 10.3)
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const HomeScreen(),
    );
  }

}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Sample products for the homepage (Requirements 1.2)
  // Use IDs that match ProductService for proper navigation
  static final List<Product> _sampleProducts = [
    Product(
      id: 'prod-8',
      title: 'Portsmouth Magnet',
      description: 'Collectible magnet featuring Portsmouth landmarks.',
      price: 5.00,
      imageUrls: [
        'https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'
      ],
      sizes: ['One Size'],
      colours: ['Multi'],
      collectionId: 'souvenirs',
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'prod-1',
      title: 'University Hoodie',
      description: 'Classic university hoodie with embroidered logo.',
      price: 35.00,
      imageUrls: [
        'https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colours: ['Navy', 'Black', 'Grey'],
      collectionId: 'clothing',
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'prod-10',
      title: 'Portsmouth Postcard Set',
      description: 'Set of 6 postcards featuring campus views.',
      price: 8.00,
      salePrice: 6.00,
      imageUrls: [
        'https://shop.upsu.net/cdn/shop/files/PortsmouthCityMagnet1_1024x1024@2x.jpg?v=1752230282'
      ],
      sizes: ['Standard'],
      colours: ['Multi'],
      collectionId: 'souvenirs',
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'prod-7',
      title: 'Campus Backpack',
      description: 'Durable backpack with laptop compartment.',
      price: 45.00,
      salePrice: 38.00,
      imageUrls: [
        'https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561'
      ],
      sizes: ['One Size'],
      colours: ['Black', 'Navy', 'Grey'],
      collectionId: 'accessories',
      createdAt: DateTime.now(),
    ),
  ];

  void _navigateToProduct(BuildContext context, String productId) {
    Navigator.pushNamed(context, '/product/$productId');
  }

  void _navigateToCollections(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.collections);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // End drawer for mobile navigation (Req 2.3)
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navbar widget (Req 1.3, 2.1, 2.2, 2.3, 2.5)
            Navbar(
              onSearchTap: () => Navigator.pushNamed(context, AppRoutes.search),
              onAccountTap: () => Navigator.pushNamed(context, AppRoutes.account),
              onCartTap: () => Navigator.pushNamed(context, AppRoutes.cart),
            ),

            // Hero Section (Req 1.1)
            _buildHeroSection(context),

            // Products Section (Req 1.2, 1.4, 1.5)
            _buildProductsSection(context),

            // Footer widget (Req 4.1, 4.2, 4.3)
            const Footer(),
          ],
        ),
      ),
    );
  }

  /// Builds the hero section with title, description, and CTA button (Req 1.1)
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Responsive sizing
    final heroHeight = isMobile ? 320.0 : (isTablet ? 360.0 : 400.0);
    final titleFontSize = isMobile ? 24.0 : (isTablet ? 28.0 : 32.0);
    final descFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final topOffset = isMobile ? 60.0 : 80.0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://shop.upsu.net/cdn/shop/files/PortsmouthCityPostcard2_1024x1024@2x.jpg?v=1752232561',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          // Content overlay
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            top: topOffset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Union Shop',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'Your one-stop shop for University of Portsmouth merchandise and souvenirs.',
                  style: TextStyle(
                    fontSize: descFontSize,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 24 : 32),
                ElevatedButton(
                  onPressed: () => _navigateToCollections(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4d2963),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 24,
                      vertical: isMobile ? 12 : 14,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'BROWSE PRODUCTS',
                    style: TextStyle(fontSize: isMobile ? 12 : 14, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the products section with responsive grid (Req 1.2, 1.4, 1.5)
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildProductsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Mobile (<600px): single column (Req 1.4, 16.1)
    // Tablet (600-1024px): 2 columns (Req 16.2)
    // Desktop (>1024px): multi-column grid (Req 1.5, 16.3)
    final crossAxisCount = _getGridCrossAxisCount(screenWidth);
    final padding = screenWidth < 600 ? 16.0 : 40.0;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Text(
              'FEATURED PRODUCTS',
              style: TextStyle(
                fontSize: screenWidth < 600 ? 18 : 20,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: screenWidth < 600 ? 24 : 48),
            // Products grid with at least 4 product cards (Req 1.2)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: screenWidth < 600 ? 12 : 24,
                mainAxisSpacing: screenWidth < 600 ? 24 : 48,
                childAspectRatio: 0.75,
              ),
              itemCount: _sampleProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: _sampleProducts[index],
                  showSaleBadge: false,
                  onTap: () => _navigateToProduct(context, _sampleProducts[index].id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Determines grid columns based on screen width
  /// Requirements: 16.1, 16.2, 16.3
  int _getGridCrossAxisCount(double width) {
    if (width < 600) {
      return 1; // Mobile: single column (Req 16.1)
    } else if (width < 1024) {
      return 2; // Tablet: 2 columns (Req 16.2)
    } else {
      return 4; // Desktop: 4 columns (Req 16.3)
    }
  }
}
