import 'package:flutter/material.dart';

/// Enum representing available sort options for products and collections.
enum SortOption {
  /// Sort by newest items first (most recent createdAt).
  newest('Newest'),

  /// Sort by price from low to high.
  priceAsc('Price: Low to High'),

  /// Sort by price from high to low.
  priceDesc('Price: High to Low'),

  /// Sort alphabetically by name (A-Z).
  nameAsc('Name: A-Z');

  /// The display label for this sort option.
  final String label;

  const SortOption(this.label);
}

/// A reusable dropdown widget for sorting options.
///
/// Displays a dropdown with predefined sort options and triggers
/// a callback when the selection changes.
class SortDropdown extends StatelessWidget {
  /// The currently selected sort option.
  final SortOption selectedOption;

  /// Callback triggered when the sort option changes.
  final ValueChanged<SortOption> onChanged;

  const SortDropdown({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sort by',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SortOption>(
              value: selectedOption,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: SortOption.values.map((option) {
                return DropdownMenuItem<SortOption>(
                  value: option,
                  child: Text(option.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
