import 'package:flutter/material.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/services/product_service.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';

/// Sale collection page displaying discounted products.
///
/// Shows a promotional banner, sale products with badges, and pricing
/// that displays both original and sale prices.
///
/// Requirements: 8.1, 8.2, 8.3, 8.4
class SalePage extends StatelessWidget {
  const SalePage({super.key});

  /// Get sale products from ProductService (Req 8.1)
  List<Product> get _saleProducts => ProductService().getSaleProducts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // End drawer for mobile navigation
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shared navbar component
            const Navbar(),

            // Promotional banner (Req 8.1, 8.3)
            _buildPromotionalBanner(context),

            // Sale products grid (Req 8.2, 8.4)
            _buildSaleProductsGrid(context),

            // Shared footer component
            const Footer(),
          ],
        ),
      ),
    );
  }


  /// Builds the promotional banner section (Req 8.1, 8.3)
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildPromotionalBanner(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Responsive sizing
    final saleTitleSize = isMobile ? 40.0 : (isTablet ? 48.0 : 56.0);
    final descSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final subDescSize = isMobile ? 14.0 : 16.0;
    final verticalPadding = isMobile ? 32.0 : 48.0;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final letterSpacing = isMobile ? 4.0 : 8.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD32F2F), // Red
            Color(0xFF4d2963), // Purple
          ],
        ),
      ),
      child: Column(
        children: [
          // Sale label badge (Req 8.3)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🔥 LIMITED TIME OFFER',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD32F2F),
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          // Main sale title
          Text(
            'SALE',
            style: TextStyle(
              fontSize: saleTitleSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: letterSpacing,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Sale description
          Text(
            'Up to 35% off selected items',
            style: TextStyle(
              fontSize: descSize,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Don\'t miss out on these amazing deals!',
            style: TextStyle(
              fontSize: subDescSize,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the responsive sale products grid (Req 8.2, 8.4)
  Widget _buildSaleProductsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Sale Items',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4d2963),
              ),
            ),
          ),
          // Products grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: _saleProducts.length,
            itemBuilder: (context, index) {
              final product = _saleProducts[index];
              // Display ProductCard with sale badges (Req 8.2, 8.4)
              return ProductCard(
                product: product,
                showSaleBadge: true,
                onTap: () {
                  Navigator.pushNamed(context, '/product/${product.id}');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Determines the number of columns based on screen width
  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 1; // Mobile: single column
    } else if (width < 900) {
      return 2; // Tablet: 2 columns
    } else if (width < 1200) {
      return 3; // Desktop: 3 columns
    } else {
      return 4; // Large desktop: 4 columns
    }
  }
}
