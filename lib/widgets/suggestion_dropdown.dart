import 'package:flutter/material.dart';
import '../models/product.dart';
import 'suggestion_item.dart';

/// A dropdown widget that displays a list of product suggestions.
///
/// Renders SuggestionItem widgets for each product, handles visibility state,
/// and shows a "No matches found" message when the suggestions list is empty.
///
/// Requirements: 1.3, 5.1, 5.2
class SuggestionDropdown extends StatelessWidget {
  /// List of products to display as suggestions
  final List<Product> suggestions;

  /// Whether the dropdown is visible
  final bool isVisible;

  /// Callback when a suggestion is selected
  final Function(Product) onSelect;

  /// Message to display when no suggestions are found
  /// Defaults to "No matches found"
  final String emptyMessage;

  /// Secondary message shown below the empty message
  /// Defaults to "Try a different search term"
  final String emptyHint;

  /// Maximum width of the dropdown
  final double? maxWidth;

  const SuggestionDropdown({
    super.key,
    required this.suggestions,
    required this.isVisible,
    required this.onSelect,
    this.emptyMessage = 'No matches found',
    this.emptyHint = 'Try a different search term',
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: suggestions.isEmpty
            ? _buildEmptyState(context)
            : _buildSuggestionsList(),
      ),
    );
  }

  /// Builds the empty state message (Req 5.1, 5.2)
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emptyHint,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of suggestion items (Req 1.3)
  Widget _buildSuggestionsList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return SuggestionItem(
          product: product,
          onTap: () => onSelect(product),
        );
      },
    );
  }
}
