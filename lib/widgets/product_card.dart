import 'package:flutter/material.dart';
import '../models/product.dart';

/// A card widget that displays a product preview in grid layouts.
///
/// Displays product image, title, and price. When the product is on sale
/// and [showSaleBadge] is true, shows the original price with strikethrough,
/// the sale price, and a sale badge.
///
/// Requirements: 8.2, 8.4
class ProductCard extends StatelessWidget {
  /// The product to display
  final Product product;

  /// Whether to show the sale badge when the product is on sale
  final bool showSaleBadge;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.showSaleBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image with optional sale badge
            _buildImageSection(),
            // Product details
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product title
                    Flexible(
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price display
                    _buildPriceSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the image section with optional sale badge overlay
  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product image
          _buildProductImage(),
          // Sale badge (Req 8.4)
          if (product.isOnSale && showSaleBadge) _buildSaleBadge(),
        ],
      ),
    );
  }

  /// Builds the product image with error handling
  Widget _buildProductImage() {
    if (product.imageUrls.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.network(
      product.imageUrls.first,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  /// Builds a placeholder image when no image is available
  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  /// Builds the sale badge overlay (Req 8.4)
  Widget _buildSaleBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Sale',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the price section with sale price display (Req 8.2)
  Widget _buildPriceSection() {
    if (product.isOnSale && showSaleBadge) {
      // Show original price struck through and sale price (Req 8.2)
      return Row(
        children: [
          // Original price with strikethrough
          Text(
            '£${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          // Sale price
          Text(
            '£${product.salePrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    }

    // Regular price display
    return Text(
      '£${product.displayPrice.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
