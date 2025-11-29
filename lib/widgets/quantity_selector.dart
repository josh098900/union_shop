import 'package:flutter/material.dart';

/// A widget that allows users to adjust quantity with +/- buttons.
///
/// Enforces minimum (default 1) and maximum constraints on the quantity value.
/// The increment button is disabled when quantity reaches max, and the
/// decrement button is disabled when quantity reaches min.
///
/// Requirements: 7.3, 13.3
class QuantitySelector extends StatelessWidget {
  /// The current quantity value
  final int quantity;

  /// Callback when the quantity changes
  final ValueChanged<int> onChanged;

  /// Minimum allowed quantity (default: 1)
  final int min;

  /// Maximum allowed quantity (default: 99)
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  }) : assert(min >= 1, 'Minimum quantity must be at least 1'),
       assert(max >= min, 'Maximum must be greater than or equal to minimum');

  /// Increments the quantity by 1, up to max
  void _increment() {
    if (quantity < max) {
      onChanged(quantity + 1);
    }
  }

  /// Decrements the quantity by 1, down to min
  void _decrement() {
    if (quantity > min) {
      onChanged(quantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = quantity > min;
    final bool canIncrement = quantity < max;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          _buildButton(
            icon: Icons.remove,
            onPressed: canDecrement ? _decrement : null,
            semanticLabel: 'Decrease quantity',
          ),
          // Quantity display
          Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Increment button
          _buildButton(
            icon: Icons.add,
            onPressed: canIncrement ? _increment : null,
            semanticLabel: 'Increase quantity',
          ),
        ],
      ),
    );
  }

  /// Builds an increment/decrement button
  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: onPressed != null ? Colors.black87 : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
