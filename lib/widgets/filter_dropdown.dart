import 'package:flutter/material.dart';

/// A reusable dropdown widget for filtering options.
///
/// Displays a labeled dropdown with selectable options and triggers
/// a callback when the selection changes.
class FilterDropdown extends StatelessWidget {
  /// The label displayed above or beside the dropdown.
  final String label;

  /// The list of available options to choose from.
  final List<String> options;

  /// The currently selected value, or null if nothing is selected.
  final String? selectedValue;

  /// Callback triggered when the selection changes.
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.options,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
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
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text('Select $label'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                // Add "All" option to clear filter
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All'),
                ),
                ...options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
