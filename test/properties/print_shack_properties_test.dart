import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/pages/print_shack_page.dart';

/// Property-based tests for Print Shack preview synchronization.
///
/// **Feature: union-shop-ecommerce, Property 10: Print Shack Preview Synchronization**
/// **Validates: Requirements 15.3**
///
/// For any text entered in the personalisation input field, the preview display
/// SHALL contain that exact text within a reasonable update interval.
void main() {
  group('Print Shack Properties', () {
    // **Feature: union-shop-ecommerce, Property 10: Print Shack Preview Synchronization**
    // **Validates: Requirements 15.3**

    group('Property 10: Preview synchronization with text input', () {
      // Test with various text inputs to verify real-time preview updates
      final testTexts = [
        'Hello',
        'Test123',
        'My Name',
        'UPPERCASE',
        'lowercase',
        'MixedCase',
        '12345',
        'A',
        'AB',
        'ABC',
        'Short',
        'Medium Length Text',
        'This is a longer text',
        'Special chars: !@#',
        'Numbers 123 456',
        'Spaces   between',
        'Portsmouth',
        'Union Shop',
        'Print Shack',
        'Custom Design',
      ];

      for (final text in testTexts) {
        testWidgets(
          'preview displays "$text" when entered in input field',
          (tester) async {
            await tester.pumpWidget(
              const MaterialApp(
                home: PrintShackPage(),
              ),
            );

            // Find the custom text input field
            final textField = find.byKey(const Key('custom_text_input'));
            expect(textField, findsOneWidget);

            // Enter text into the input field
            await tester.enterText(textField, text);
            await tester.pump();

            // Find the preview text container and verify it contains the text
            final previewTextContainer = find.byKey(const Key('preview_text'));
            expect(
              previewTextContainer,
              findsOneWidget,
              reason: 'Preview text container should appear when text is entered',
            );

            // Find the Text widget inside the preview container
            final textFinder = find.descendant(
              of: previewTextContainer,
              matching: find.byType(Text),
            );
            expect(textFinder, findsOneWidget);

            final textWidget = tester.widget<Text>(textFinder);
            expect(
              textWidget.data,
              equals(text),
              reason: 'Preview text should exactly match input: "$text"',
            );
          },
        );
      }
    });

    group('Property 10: Preview updates immediately on text change', () {
      // Test that preview updates as text is modified
      testWidgets(
        'preview updates when text is modified character by character',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: PrintShackPage(),
            ),
          );

          final textField = find.byKey(const Key('custom_text_input'));

          // Type characters one by one and verify preview updates
          final testWord = 'Hello';
          for (int i = 1; i <= testWord.length; i++) {
            final partialText = testWord.substring(0, i);
            await tester.enterText(textField, partialText);
            await tester.pump();

            final previewTextContainer = find.byKey(const Key('preview_text'));
            expect(previewTextContainer, findsOneWidget);

            final textFinder = find.descendant(
              of: previewTextContainer,
              matching: find.byType(Text),
            );
            final textWidget = tester.widget<Text>(textFinder);
            expect(
              textWidget.data,
              equals(partialText),
              reason: 'Preview should show "$partialText" after typing $i chars',
            );
          }
        },
      );

      testWidgets(
        'preview disappears when text is cleared',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: PrintShackPage(),
            ),
          );

          final textField = find.byKey(const Key('custom_text_input'));

          // Enter text first
          await tester.enterText(textField, 'Test');
          await tester.pump();

          // Verify preview appears
          expect(find.byKey(const Key('preview_text')), findsOneWidget);

          // Clear the text
          await tester.enterText(textField, '');
          await tester.pump();

          // Verify preview text is gone
          expect(
            find.byKey(const Key('preview_text')),
            findsNothing,
            reason: 'Preview text should disappear when input is empty',
          );
        },
      );
    });

    group('Property 10: Preview synchronization with various string lengths', () {
      // Test with strings of different lengths (1 to 30 characters)
      for (int length = 1; length <= 30; length++) {
        final text = 'A' * length;
        testWidgets(
          'preview displays text of length $length correctly',
          (tester) async {
            await tester.pumpWidget(
              const MaterialApp(
                home: PrintShackPage(),
              ),
            );

            final textField = find.byKey(const Key('custom_text_input'));
            await tester.enterText(textField, text);
            await tester.pump();

            final previewTextContainer = find.byKey(const Key('preview_text'));
            expect(previewTextContainer, findsOneWidget);

            final textFinder = find.descendant(
              of: previewTextContainer,
              matching: find.byType(Text),
            );
            final textWidget = tester.widget<Text>(textFinder);
            expect(
              textWidget.data,
              equals(text),
              reason: 'Preview should display $length character(s)',
            );
          },
        );
      }
    });

    group('Property 10: Preview synchronization with alphanumeric combinations', () {
      // Generate various alphanumeric combinations
      final alphanumericTests = <String>[];
      
      // Letters only
      for (var c = 'A'.codeUnitAt(0); c <= 'Z'.codeUnitAt(0); c++) {
        alphanumericTests.add(String.fromCharCode(c));
      }
      
      // Numbers only
      for (var n = 0; n <= 9; n++) {
        alphanumericTests.add(n.toString());
      }
      
      // Mixed combinations
      alphanumericTests.addAll([
        'A1',
        'B2C',
        '1A2B',
        'Test1',
        '2Test',
        'ABC123',
        '123ABC',
        'a1b2c3',
      ]);

      for (final text in alphanumericTests) {
        testWidgets(
          'preview displays alphanumeric "$text" correctly',
          (tester) async {
            await tester.pumpWidget(
              const MaterialApp(
                home: PrintShackPage(),
              ),
            );

            final textField = find.byKey(const Key('custom_text_input'));
            await tester.enterText(textField, text);
            await tester.pump();

            final previewTextContainer = find.byKey(const Key('preview_text'));
            expect(previewTextContainer, findsOneWidget);

            final textFinder = find.descendant(
              of: previewTextContainer,
              matching: find.byType(Text),
            );
            final textWidget = tester.widget<Text>(textFinder);
            expect(
              textWidget.data,
              equals(text),
              reason: 'Preview should exactly match alphanumeric input: "$text"',
            );
          },
        );
      }
    });

    group('Property 10: Preview container exists', () {
      testWidgets(
        'preview container is always present',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: PrintShackPage(),
            ),
          );

          // Preview container should always exist
          final previewContainer = find.byKey(const Key('preview_container'));
          expect(
            previewContainer,
            findsOneWidget,
            reason: 'Preview container should always be present',
          );
        },
      );
    });
  });
}
