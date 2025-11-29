import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/widgets/quantity_selector.dart';

/// Property-based tests for QuantitySelector widget.
///
/// **Feature: union-shop-ecommerce, Property 7: Quantity Selector State Consistency**
/// **Validates: Requirements 13.3**
///
/// For any quantity selector with a current value, incrementing SHALL
/// increase the value by 1 (up to max), and decrementing SHALL decrease
/// the value by 1 (down to min of 1).
///
/// Since glados conflicts with flutter_test, we implement property-based
/// testing manually by iterating over a range of values.
void main() {
  group('QuantitySelector Properties', () {
    // **Feature: union-shop-ecommerce, Property 7: Quantity Selector State Consistency**
    // **Validates: Requirements 13.3**

    group('Property 7: Incrementing increases quantity by 1 up to max', () {
      // Test across 100+ combinations of quantity, min, and max values
      for (int min = 1; min <= 5; min++) {
        for (int max = 10; max <= 15; max++) {
          for (int quantity = min; quantity <= max; quantity++) {
            testWidgets(
              'increment from quantity=$quantity (min=$min, max=$max)',
              (tester) async {
                int? newValue;

                await tester.pumpWidget(
                  MaterialApp(
                    home: Scaffold(
                      body: QuantitySelector(
                        quantity: quantity,
                        min: min,
                        max: max,
                        onChanged: (value) => newValue = value,
                      ),
                    ),
                  ),
                );

                // Find and tap the increment button
                final incrementButton = find.byIcon(Icons.add);
                expect(incrementButton, findsOneWidget);

                await tester.tap(incrementButton);
                await tester.pump();

                if (quantity < max) {
                  // Should increment by 1
                  expect(
                    newValue,
                    equals(quantity + 1),
                    reason:
                        'Incrementing from $quantity should give ${quantity + 1}',
                  );
                } else {
                  // At max, should not change
                  expect(
                    newValue,
                    isNull,
                    reason: 'At max=$max, increment should not trigger callback',
                  );
                }
              },
            );
          }
        }
      }
    });

    group('Property 7: Decrementing decreases quantity by 1 down to min', () {
      // Test across 100+ combinations of quantity, min, and max values
      for (int min = 1; min <= 5; min++) {
        for (int max = 10; max <= 15; max++) {
          for (int quantity = min; quantity <= max; quantity++) {
            testWidgets(
              'decrement from quantity=$quantity (min=$min, max=$max)',
              (tester) async {
                int? newValue;

                await tester.pumpWidget(
                  MaterialApp(
                    home: Scaffold(
                      body: QuantitySelector(
                        quantity: quantity,
                        min: min,
                        max: max,
                        onChanged: (value) => newValue = value,
                      ),
                    ),
                  ),
                );

                // Find and tap the decrement button
                final decrementButton = find.byIcon(Icons.remove);
                expect(decrementButton, findsOneWidget);

                await tester.tap(decrementButton);
                await tester.pump();

                if (quantity > min) {
                  // Should decrement by 1
                  expect(
                    newValue,
                    equals(quantity - 1),
                    reason:
                        'Decrementing from $quantity should give ${quantity - 1}',
                  );
                } else {
                  // At min, should not change
                  expect(
                    newValue,
                    isNull,
                    reason: 'At min=$min, decrement should not trigger callback',
                  );
                }
              },
            );
          }
        }
      }
    });

    group('Property 7: Boundary conditions', () {
      // Test at exact boundaries with various min/max combinations
      for (int min = 1; min <= 10; min++) {
        final max = min + 20;

        testWidgets(
          'at minimum value $min, decrement does not change quantity',
          (tester) async {
            int? newValue;

            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: QuantitySelector(
                    quantity: min,
                    min: min,
                    max: max,
                    onChanged: (value) => newValue = value,
                  ),
                ),
              ),
            );

            final decrementButton = find.byIcon(Icons.remove);
            await tester.tap(decrementButton);
            await tester.pump();

            expect(
              newValue,
              isNull,
              reason: 'At min=$min, decrement should not trigger callback',
            );
          },
        );

        testWidgets(
          'at maximum value $max, increment does not change quantity',
          (tester) async {
            int? newValue;

            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: QuantitySelector(
                    quantity: max,
                    min: min,
                    max: max,
                    onChanged: (value) => newValue = value,
                  ),
                ),
              ),
            );

            final incrementButton = find.byIcon(Icons.add);
            await tester.tap(incrementButton);
            await tester.pump();

            expect(
              newValue,
              isNull,
              reason: 'At max=$max, increment should not trigger callback',
            );
          },
        );
      }
    });

    group('Property 7: Quantity display correctness', () {
      // Verify the displayed quantity matches the input
      for (int quantity = 1; quantity <= 20; quantity++) {
        testWidgets(
          'displays quantity $quantity correctly',
          (tester) async {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: QuantitySelector(
                    quantity: quantity,
                    min: 1,
                    max: 99,
                    onChanged: (_) {},
                  ),
                ),
              ),
            );

            expect(
              find.text(quantity.toString()),
              findsOneWidget,
              reason: 'Should display quantity $quantity',
            );
          },
        );
      }
    });
  });
}
