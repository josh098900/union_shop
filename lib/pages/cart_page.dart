import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/cart_item_widget.dart';

/// Cart page displaying all cart items with totals and checkout functionality.
///
/// Shows:
/// - List of cart items with quantity controls and remove buttons
/// - Subtotal, tax, and total calculations
/// - Checkout button
/// - Empty cart state with continue shopping link
///
/// Requirements: 14.2, 14.3, 14.4, 18.3
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const Color primaryColor = Color(0xFF4d2963);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildCartContent(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoading) {
          return _buildLoadingState();
        }

        if (cartProvider.isEmpty) {
          return _buildEmptyCartState(context);
        }

        return _buildCartWithItems(context, cartProvider);
      },
    );
  }

  /// Loading state while cart is being fetched
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }

  /// Empty cart state with message and continue shopping link (Req 14.4)
  Widget _buildEmptyCartState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added any items yet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/collections');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cart with items layout
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildCartWithItems(BuildContext context, CartProvider cartProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 900;
    
    // Responsive sizing
    final titleSize = isMobile ? 24.0 : 28.0;
    final padding = isMobile ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.all(padding),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          Text(
            'Shopping Cart',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'item' : 'items'}',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          // Cart content
          if (isDesktop)
            _buildDesktopLayout(context, cartProvider)
          else
            _buildMobileLayout(context, cartProvider),
        ],
      ),
    );
  }

  /// Desktop layout with side-by-side cart items and summary
  Widget _buildDesktopLayout(BuildContext context, CartProvider cartProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cart items list
        Expanded(
          flex: 2,
          child: _buildCartItemsList(context, cartProvider),
        ),
        const SizedBox(width: 32),
        // Order summary
        Expanded(
          flex: 1,
          child: _buildOrderSummary(context, cartProvider),
        ),
      ],
    );
  }

  /// Mobile layout with stacked cart items and summary
  Widget _buildMobileLayout(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        _buildCartItemsList(context, cartProvider),
        const SizedBox(height: 24),
        _buildOrderSummary(context, cartProvider),
      ],
    );
  }

  /// List of cart items (Req 14.2)
  Widget _buildCartItemsList(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        // Desktop header row
        if (MediaQuery.of(context).size.width >= 900)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 48), // Space for remove button
              ],
            ),
          ),
        // Cart items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartProvider.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = cartProvider.items[index];
            return CartItemWidget(
              item: item,
              onQuantityChanged: (newQuantity) {
                cartProvider.updateQuantity(item.id, newQuantity);
              },
              onRemove: () {
                _showRemoveConfirmation(context, cartProvider, item.id);
              },
            );
          },
        ),
      ],
    );
  }

  /// Order summary with totals and checkout button (Req 18.3, 14.3)
  Widget _buildOrderSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Subtotal
          _buildSummaryRow(
            'Subtotal',
            '£${cartProvider.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          // Tax (VAT)
          _buildSummaryRow(
            'VAT (20%)',
            '£${cartProvider.tax.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          // Total
          _buildSummaryRow(
            'Total',
            '£${cartProvider.total.toStringAsFixed(2)}',
            isBold: true,
            fontSize: 18,
          ),
          const SizedBox(height: 24),
          // Checkout button (Req 14.3)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleCheckout(context, cartProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Continue shopping link
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/collections');
              },
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a summary row with label and value
  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Shows confirmation dialog before removing an item
  void _showRemoveConfirmation(
    BuildContext context,
    CartProvider cartProvider,
    String itemId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text(
          'Are you sure you want to remove this item from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cartProvider.removeFromCart(itemId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Handles checkout button press (Req 14.3)
  void _handleCheckout(BuildContext context, CartProvider cartProvider) {
    // Simulate placing an order and display confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Order Placed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for your order!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Order Total: £${cartProvider.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items: ${cartProvider.itemCount}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cartProvider.clearCart();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}
