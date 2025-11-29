import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'quantity_selector.dart';

/// A widget that displays a single cart item with product details,
/// quantity controls, and a remove button.
///
/// Requirements: 14.2
class CartItemWidget extends StatelessWidget {
  /// The cart item to display
  final CartItem item;

  /// Callback when quantity is changed
  final ValueChanged<int> onQuantityChanged;

  /// Callback when remove button is pressed
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  static const Color primaryColor = Color(0xFF4d2963);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            _buildProductImage(size: 80),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductTitle(),
                  const SizedBox(height: 4),
                  _buildProductOptions(),
                ],
              ),
            ),
            // Remove button
            _buildRemoveButton(),
          ],
        ),
        const SizedBox(height: 12),
        // Quantity and price row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuantitySelector(),
            _buildPriceDisplay(),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product image
        _buildProductImage(size: 100),
        const SizedBox(width: 16),
        // Product details
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductTitle(),
              const SizedBox(height: 4),
              _buildProductOptions(),
            ],
          ),
        ),
        // Quantity selector
        Expanded(
          flex: 2,
          child: Center(child: _buildQuantitySelector()),
        ),
        // Price
        Expanded(
          flex: 1,
          child: _buildPriceDisplay(),
        ),
        // Remove button
        _buildRemoveButton(),
      ],
    );
  }

  /// Builds the product image with error handling
  Widget _buildProductImage({required double size}) {
    final imageUrl = item.product.imageUrls.isNotEmpty
        ? item.product.imageUrls.first
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder(size);
              },
            )
          : _buildImagePlaceholder(size),
    );
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: size * 0.4,
      ),
    );
  }

  /// Builds the product title
  Widget _buildProductTitle() {
    return Text(
      item.product.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the product options (size, colour, custom text)
  Widget _buildProductOptions() {
    final options = <String>[];

    if (item.selectedSize != null && item.selectedSize!.isNotEmpty) {
      options.add('Size: ${item.selectedSize}');
    }
    if (item.selectedColour != null && item.selectedColour!.isNotEmpty) {
      options.add('Colour: ${item.selectedColour}');
    }
    if (item.customText != null && item.customText!.isNotEmpty) {
      options.add('Custom: ${item.customText}');
    }

    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      options.join(' • '),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the quantity selector
  Widget _buildQuantitySelector() {
    return QuantitySelector(
      quantity: item.quantity,
      onChanged: onQuantityChanged,
      min: 1,
      max: 99,
    );
  }

  /// Builds the price display
  Widget _buildPriceDisplay() {
    final product = item.product;
    final isOnSale = product.isOnSale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Item total price
        Text(
          '£${item.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        // Unit price (with sale indication if applicable)
        if (isOnSale) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '£${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '£${product.salePrice!.toStringAsFixed(2)} each',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 2),
          Text(
            '£${product.displayPrice.toStringAsFixed(2)} each',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the remove button
  Widget _buildRemoveButton() {
    return IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.close),
      color: Colors.grey[600],
      tooltip: 'Remove item',
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
    );
  }
}
