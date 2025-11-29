import 'package:flutter/material.dart';
import '../models/product.dart';

/// A widget that displays a single product suggestion in the autocomplete dropdown.
///
/// Shows the product name and price, and handles tap interactions for selection.
/// Styled consistently with the app theme.
///
/// Requirements: 1.4, 2.1
class SuggestionItem extends StatelessWidget {
  /// The product to display
  final Product product;

  /// Callback when the suggestion is tapped
  final VoidCallback onTap;

  const SuggestionItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Product name (Req 1.4)
            Expanded(
              child: Text(
                product.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Product price (Req 1.4)
            _buildPriceDisplay(),
          ],
        ),
      ),
    );
  }

  /// Builds the price display, showing sale price if applicable
  Widget _buildPriceDisplay() {
    if (product.isOnSale) {
      return Row(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 6),
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
