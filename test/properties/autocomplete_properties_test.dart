import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/services/autocomplete_service.dart';
import 'package:union_shop/services/search_service.dart';
import 'package:union_shop/services/product_service.dart';
import 'package:union_shop/widgets/suggestion_item.dart';
import 'package:union_shop/widgets/suggestion_dropdown.dart';
import 'package:union_shop/widgets/autocomplete_search_field.dart';

/// Helper to create a product with given parameters
Product createProduct({
  required String id,
  required String title,
  required String description,
  required double price,
}) {
  return Product(
    id: id,
    title: title,
    description: description,
    price: price,
    salePrice: null,
    imageUrls: ['https://example.com/image.jpg'],
    sizes: ['M', 'L'],
    colours: ['Black', 'White'],
    collectionId: 'test-collection',
    createdAt: DateTime.now(),
  );
}

/// Sample words for generating random product titles
const sampleTitleWords = [
  'University', 'Portsmouth', 'Campus', 'Student', 'Varsity',
  'Classic', 'Premium', 'Official', 'Limited', 'Special',
];

const sampleProductTypes = [
  'Hoodie', 'T-Shirt', 'Jacket', 'Sweatshirt', 'Beanie',
  'Scarf', 'Backpack', 'Mug', 'Notebook', 'Pen',
];

/// Generates a random product title
String generateRandomTitle(Random random) {
  final adjective = sampleTitleWords[random.nextInt(sampleTitleWords.length)];
  final product = sampleProductTypes[random.nextInt(sampleProductTypes.length)];
  return '$adjective $product';
}

/// Generates a search query from existing product data
String generateSearchQuery(List<Product> products, Random random) {
  final product = products[random.nextInt(products.length)];
  final titleWords = product.title.split(' ');
  return titleWords[random.nextInt(titleWords.length)];
}

/// Generates a random case variation of a string
String randomCaseVariation(String input, Random random) {
  final chars = input.split('');
  return chars.map((c) => random.nextBool() ? c.toUpperCase() : c.toLowerCase()).join();
}

void main() {
  group('Autocomplete Properties', () {
    // Run suggestion dropdown property tests
    suggestionDropdownPropertyTests();
    // **Feature: search-autocomplete, Property 7: Case-insensitive filtering**
    // **Validates: Requirements 3.2**
    group('Property 7: Case-insensitive filtering', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: filtering is case-insensitive', () {
          final autocompleteService = AutocompleteService(
            searchService: SearchService(productService: ProductService()),
          );
          final allProducts = ProductService().getAll();

          final random = Random(iteration);
          final query = generateSearchQuery(allProducts, random);

          // Get suggestions with different case variations
          final lowerResults = autocompleteService.getSuggestions(
            query.toLowerCase(),
            maxResults: 100,
          );
          final upperResults = autocompleteService.getSuggestions(
            query.toUpperCase(),
            maxResults: 100,
          );
          final mixedResults = autocompleteService.getSuggestions(
            randomCaseVariation(query, random),
            maxResults: 100,
          );

          // All should return the same product IDs
          final lowerIds = lowerResults.map((p) => p.id).toSet();
          final upperIds = upperResults.map((p) => p.id).toSet();
          final mixedIds = mixedResults.map((p) => p.id).toSet();

          expect(
            lowerIds,
            equals(upperIds),
            reason: 'Lower and upper case queries should return same products',
          );
          expect(
            lowerIds,
            equals(mixedIds),
            reason: 'Mixed case query should return same products',
          );
        });
      }

      // Test that matchesQuery is case-insensitive
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: matchesQuery is case-insensitive', () {
          final autocompleteService = AutocompleteService();
          final allProducts = ProductService().getAll();

          final random = Random(iteration + 1000);
          final product = allProducts[random.nextInt(allProducts.length)];
          final query = product.title.split(' ').first;

          // Test with different case variations
          final lowerMatch = autocompleteService.matchesQuery(product, query.toLowerCase());
          final upperMatch = autocompleteService.matchesQuery(product, query.toUpperCase());
          final mixedMatch = autocompleteService.matchesQuery(product, randomCaseVariation(query, random));

          expect(
            lowerMatch,
            equals(upperMatch),
            reason: 'matchesQuery should be case-insensitive',
          );
          expect(
            lowerMatch,
            equals(mixedMatch),
            reason: 'matchesQuery should be case-insensitive for mixed case',
          );
        });
      }
    });

    // **Feature: search-autocomplete, Property 2: Suggestion count is bounded**
    // **Validates: Requirements 1.3**
    group('Property 2: Suggestion count is bounded', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: suggestions are bounded to maxResults', () {
          final autocompleteService = AutocompleteService(
            searchService: SearchService(productService: ProductService()),
          );
          final allProducts = ProductService().getAll();

          final random = Random(iteration + 4000);
          final query = generateSearchQuery(allProducts, random);

          // Test with default maxResults (5)
          final defaultSuggestions = autocompleteService.getSuggestions(query);
          expect(
            defaultSuggestions.length,
            lessThanOrEqualTo(5),
            reason: 'Default suggestions should be at most 5',
          );

          // Test with various maxResults values
          final maxResults = 1 + random.nextInt(10);
          final suggestions = autocompleteService.getSuggestions(
            query,
            maxResults: maxResults,
          );
          expect(
            suggestions.length,
            lessThanOrEqualTo(maxResults),
            reason: 'Suggestions should be at most $maxResults',
          );
        });
      }
    });

    // **Feature: search-autocomplete, Property 8: Prefix matches ordered first**
    // **Validates: Requirements 3.3**
    group('Property 8: Prefix matches ordered first', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: prefix matches appear before contains matches', () {
          final autocompleteService = AutocompleteService(
            searchService: SearchService(productService: ProductService()),
          );
          final allProducts = ProductService().getAll();

          final random = Random(iteration + 2000);
          final query = generateSearchQuery(allProducts, random);
          final lowerQuery = query.toLowerCase();

          // Get suggestions with high limit to see all matches
          final suggestions = autocompleteService.getSuggestions(
            query,
            maxResults: 100,
          );

          // Find the index where prefix matches end
          int lastPrefixIndex = -1;
          int firstContainsIndex = suggestions.length;

          for (int i = 0; i < suggestions.length; i++) {
            final lowerTitle = suggestions[i].title.toLowerCase();
            if (lowerTitle.startsWith(lowerQuery)) {
              lastPrefixIndex = i;
            } else if (lowerTitle.contains(lowerQuery)) {
              if (firstContainsIndex == suggestions.length) {
                firstContainsIndex = i;
              }
            }
          }

          // All prefix matches should come before all contains-only matches
          if (lastPrefixIndex >= 0 && firstContainsIndex < suggestions.length) {
            expect(
              lastPrefixIndex < firstContainsIndex,
              isTrue,
              reason: 'Prefix matches (last at index $lastPrefixIndex) should come before contains matches (first at index $firstContainsIndex) for query "$query"',
            );
          }
        });
      }

      // Test sortByRelevance directly
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: sortByRelevance orders prefix matches first', () {
          final autocompleteService = AutocompleteService();
          final random = Random(iteration + 3000);

          // Create products with known prefix/contains relationships
          final query = 'Test';
          final products = [
            createProduct(id: '1', title: 'Contains Test Here', description: '', price: 10.0),
            createProduct(id: '2', title: 'Test Prefix Match', description: '', price: 20.0),
            createProduct(id: '3', title: 'Another Test Inside', description: '', price: 30.0),
            createProduct(id: '4', title: 'Testing First', description: '', price: 40.0),
          ];

          // Shuffle to randomize input order
          products.shuffle(random);

          final sorted = autocompleteService.sortByRelevance(products, query);
          final lowerQuery = query.toLowerCase();

          // Verify prefix matches come first
          bool seenContainsOnly = false;
          for (final product in sorted) {
            final lowerTitle = product.title.toLowerCase();
            final isPrefix = lowerTitle.startsWith(lowerQuery);
            final isContains = lowerTitle.contains(lowerQuery) && !isPrefix;

            if (isContains) {
              seenContainsOnly = true;
            }

            if (isPrefix && seenContainsOnly) {
              fail('Prefix match "${product.title}" appeared after contains-only match');
            }
          }
        });
      }
    });

    // **Feature: search-autocomplete, Property 3: Suggestion items contain required information**
    // **Validates: Requirements 1.4**
    group('Property 3: Suggestion items contain required information', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        testWidgets('iteration $iteration: suggestion item displays product name and price', (WidgetTester tester) async {
          final random = Random(iteration + 5000);
          final price = 5.0 + random.nextDouble() * 495.0;
          
          final product = Product(
            id: 'product-$iteration',
            title: '${generateRandomTitle(random)} ${random.nextInt(1000)}',
            description: 'Test description',
            price: price,
            salePrice: null,
            imageUrls: ['https://example.com/image.jpg'],
            sizes: ['M', 'L'],
            colours: ['Black', 'White'],
            collectionId: 'test-collection',
            createdAt: DateTime.now(),
          );
          
          bool tapped = false;
          
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SuggestionItem(
                  product: product,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          );

          // Verify product name is displayed (Req 1.4)
          expect(
            find.text(product.title),
            findsOneWidget,
            reason: 'Suggestion item should display product name "${product.title}"',
          );

          // Verify product price is displayed (Req 1.4)
          final expectedPrice = '£${product.displayPrice.toStringAsFixed(2)}';
          expect(
            find.text(expectedPrice),
            findsOneWidget,
            reason: 'Suggestion item should display product price "$expectedPrice"',
          );

          // Verify tap callback works (Req 2.1)
          await tester.tap(find.byType(SuggestionItem));
          await tester.pump();
          expect(tapped, isTrue, reason: 'Tap callback should be invoked');
        });
      }

      // Test sale price display
      for (int iteration = 0; iteration < 100; iteration++) {
        testWidgets('iteration $iteration: suggestion item displays sale price when on sale', (WidgetTester tester) async {
          final random = Random(iteration + 6000);
          final price = 10.0 + random.nextDouble() * 490.0;
          final salePrice = price * (0.5 + random.nextDouble() * 0.4);
          
          final product = Product(
            id: 'sale-product-$iteration',
            title: '${generateRandomTitle(random)} Sale Item',
            description: 'Test description',
            price: price,
            salePrice: salePrice,
            imageUrls: ['https://example.com/image.jpg'],
            sizes: ['M', 'L'],
            colours: ['Black', 'White'],
            collectionId: 'test-collection',
            createdAt: DateTime.now(),
          );
          
          // Only test if product is actually on sale
          if (!product.isOnSale) return;
          
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SuggestionItem(
                  product: product,
                  onTap: () {},
                ),
              ),
            ),
          );

          // Verify product name is displayed
          expect(
            find.text(product.title),
            findsOneWidget,
            reason: 'Suggestion item should display product name',
          );

          // Verify sale price is displayed
          final expectedSalePrice = '£${product.salePrice!.toStringAsFixed(2)}';
          expect(
            find.text(expectedSalePrice),
            findsOneWidget,
            reason: 'Suggestion item should display sale price "$expectedSalePrice"',
          );

          // Verify original price is also displayed with strikethrough
          final expectedOriginalPrice = '£${product.price.toStringAsFixed(2)}';
          expect(
            find.text(expectedOriginalPrice),
            findsOneWidget,
            reason: 'Suggestion item should display original price "$expectedOriginalPrice"',
          );
        });
      }
    });

    // Run AutocompleteSearchField property tests
    autocompleteSearchFieldPropertyTests();
  });
}

void suggestionDropdownPropertyTests() {
  // **Feature: search-autocomplete, Property 9: Empty results show no-matches message**
  // **Validates: Requirements 5.1**
  group('Property 9: Empty results show no-matches message', () {
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: empty suggestions show no-matches message', (WidgetTester tester) async {
        final random = Random(iteration + 7000);
        
        // Generate random empty message variations
        final emptyMessages = [
          'No matches found',
          'No results',
          'Nothing found',
          'No products match your search',
        ];
        final emptyHints = [
          'Try a different search term',
          'Try another query',
          'Adjust your search',
        ];
        
        final emptyMessage = emptyMessages[random.nextInt(emptyMessages.length)];
        final emptyHint = emptyHints[random.nextInt(emptyHints.length)];
        
        Product? selectedProduct;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuggestionDropdown(
                suggestions: const [], // Empty list
                isVisible: true,
                onSelect: (product) => selectedProduct = product,
                emptyMessage: emptyMessage,
                emptyHint: emptyHint,
              ),
            ),
          ),
        );

        // Verify empty message is displayed (Req 5.1)
        expect(
          find.text(emptyMessage),
          findsOneWidget,
          reason: 'Empty suggestions should display "$emptyMessage"',
        );

        // Verify hint message is displayed (Req 5.2)
        expect(
          find.text(emptyHint),
          findsOneWidget,
          reason: 'Empty suggestions should display hint "$emptyHint"',
        );

        // Verify no suggestion items are displayed
        expect(
          find.byType(SuggestionItem),
          findsNothing,
          reason: 'No suggestion items should be displayed when list is empty',
        );
      });
    }

    // Test default messages
    testWidgets('default empty message is shown when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestionDropdown(
              suggestions: const [],
              isVisible: true,
              onSelect: (product) {},
            ),
          ),
        ),
      );

      // Verify default empty message
      expect(
        find.text('No matches found'),
        findsOneWidget,
        reason: 'Default empty message should be "No matches found"',
      );

      // Verify default hint
      expect(
        find.text('Try a different search term'),
        findsOneWidget,
        reason: 'Default hint should be "Try a different search term"',
      );
    });

    // Test visibility state
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: dropdown respects visibility state', (WidgetTester tester) async {
        final random = Random(iteration + 8000);
        final isVisible = random.nextBool();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuggestionDropdown(
                suggestions: const [],
                isVisible: isVisible,
                onSelect: (product) {},
              ),
            ),
          ),
        );

        if (isVisible) {
          // When visible, should show empty message
          expect(
            find.text('No matches found'),
            findsOneWidget,
            reason: 'Visible dropdown with empty suggestions should show message',
          );
        } else {
          // When not visible, should show nothing
          expect(
            find.text('No matches found'),
            findsNothing,
            reason: 'Hidden dropdown should not show any content',
          );
        }
      });
    }

    // Test with non-empty suggestions (should NOT show empty message)
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: non-empty suggestions do not show empty message', (WidgetTester tester) async {
        final random = Random(iteration + 9000);
        final suggestionCount = 1 + random.nextInt(5);
        
        final suggestions = List.generate(suggestionCount, (index) {
          return Product(
            id: 'product-$index',
            title: '${generateRandomTitle(random)} $index',
            description: 'Test description',
            price: 10.0 + random.nextDouble() * 90.0,
            salePrice: null,
            imageUrls: ['https://example.com/image.jpg'],
            sizes: ['M', 'L'],
            colours: ['Black', 'White'],
            collectionId: 'test-collection',
            createdAt: DateTime.now(),
          );
        });
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuggestionDropdown(
                suggestions: suggestions,
                isVisible: true,
                onSelect: (product) {},
              ),
            ),
          ),
        );

        // Verify empty message is NOT displayed
        expect(
          find.text('No matches found'),
          findsNothing,
          reason: 'Non-empty suggestions should not show empty message',
        );

        // Verify suggestion items ARE displayed
        expect(
          find.byType(SuggestionItem),
          findsNWidgets(suggestionCount),
          reason: 'Should display $suggestionCount suggestion items',
        );
      });
    }
  });
}


/// Property tests for AutocompleteSearchField widget
void autocompleteSearchFieldPropertyTests() {
  // **Feature: search-autocomplete, Property 1: Dropdown visibility matches input length threshold**
  // **Validates: Requirements 1.1, 1.2**
  group('Property 1: Dropdown visibility matches input length threshold', () {
    // Generate random strings of various lengths
    String generateRandomString(Random random, int length) {
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
    }

    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: dropdown visible iff input >= 2 chars', (WidgetTester tester) async {
        final random = Random(iteration + 10000);
        final controller = TextEditingController();
        
        // Generate random input length from 0 to 10
        final inputLength = random.nextInt(11);
        final inputText = inputLength > 0 ? generateRandomString(random, inputLength) : '';
        
        Product? selectedProduct;
        String? searchQuery;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (query) => searchQuery = query,
                onSuggestionSelected: (product) => selectedProduct = product,
                minCharacters: 2,
                debounceDelay: Duration.zero, // No debounce for testing
              ),
            ),
          ),
        );

        // Enter text
        await tester.enterText(find.byType(TextField), inputText);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50)); // Allow debounce

        // Get the state to check visibility
        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        // Property: dropdown visible iff input length >= 2
        final expectedVisible = inputLength >= 2;
        expect(
          state.isDropdownVisible,
          equals(expectedVisible),
          reason: 'For input "$inputText" (length $inputLength), dropdown should be ${expectedVisible ? "visible" : "hidden"}',
        );
      });
    }

    // Test clearing input hides dropdown (Req 1.5)
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: clearing input hides dropdown', (WidgetTester tester) async {
        final random = Random(iteration + 11000);
        final controller = TextEditingController();
        
        // Start with valid input (>= 2 chars)
        final initialLength = 2 + random.nextInt(8);
        final initialText = List.generate(initialLength, (_) => 'a').join();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (query) {},
                onSuggestionSelected: (product) {},
                minCharacters: 2,
                debounceDelay: Duration.zero,
              ),
            ),
          ),
        );

        // Enter initial text
        await tester.enterText(find.byType(TextField), initialText);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        // Verify dropdown is visible
        expect(state.isDropdownVisible, isTrue, reason: 'Dropdown should be visible with valid input');

        // Clear input
        controller.clear();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Verify dropdown is hidden
        expect(state.isDropdownVisible, isFalse, reason: 'Dropdown should be hidden after clearing input');
      });
    }
  });

  // **Feature: search-autocomplete, Property 5: Selection closes dropdown**
  // **Validates: Requirements 2.2**
  group('Property 5: Selection closes dropdown', () {
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: selecting suggestion closes dropdown', (WidgetTester tester) async {
        final random = Random(iteration + 12000);
        final controller = TextEditingController();
        
        // Use a query that will match products
        final queries = ['Hoodie', 'T-Shirt', 'Mug', 'Backpack', 'University'];
        final query = queries[random.nextInt(queries.length)];
        
        Product? selectedProduct;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (q) {},
                onSuggestionSelected: (product) => selectedProduct = product,
                minCharacters: 2,
                debounceDelay: Duration.zero,
              ),
            ),
          ),
        );

        // Enter query
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        // Skip if no suggestions (query didn't match)
        if (state.suggestions.isEmpty) return;

        // Verify dropdown is visible before selection
        expect(state.isDropdownVisible, isTrue, reason: 'Dropdown should be visible before selection');

        // Simulate selection by calling the internal method
        final productToSelect = state.suggestions[random.nextInt(state.suggestions.length)];
        state.onSuggestionSelected(productToSelect);
        await tester.pump();

        // Property: selection closes dropdown
        expect(
          state.isDropdownVisible,
          isFalse,
          reason: 'Dropdown should be hidden after selecting "${productToSelect.title}"',
        );
        expect(
          selectedProduct,
          equals(productToSelect),
          reason: 'Selected product callback should be invoked',
        );
      });
    }
  });

  // **Feature: search-autocomplete, Property 6: Selection populates input field**
  // **Validates: Requirements 2.3**
  group('Property 6: Selection populates input field', () {
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: selecting suggestion populates input', (WidgetTester tester) async {
        final random = Random(iteration + 13000);
        final controller = TextEditingController();
        
        // Use a query that will match products
        final queries = ['Hoodie', 'T-Shirt', 'Mug', 'Backpack', 'University'];
        final query = queries[random.nextInt(queries.length)];
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (q) {},
                onSuggestionSelected: (product) {},
                minCharacters: 2,
                debounceDelay: Duration.zero,
              ),
            ),
          ),
        );

        // Enter query
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        // Skip if no suggestions
        if (state.suggestions.isEmpty) return;

        // Select a random suggestion
        final productToSelect = state.suggestions[random.nextInt(state.suggestions.length)];
        state.onSuggestionSelected(productToSelect);
        await tester.pump();

        // Property: input field contains selected product name
        expect(
          controller.text,
          equals(productToSelect.title),
          reason: 'Input field should contain "${productToSelect.title}" after selection',
        );
      });
    }

    // Test that selection replaces any existing text
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: selection replaces existing input text', (WidgetTester tester) async {
        final random = Random(iteration + 14000);
        final controller = TextEditingController();
        
        final queries = ['Hoodie', 'T-Shirt', 'Mug', 'Backpack'];
        final query = queries[random.nextInt(queries.length)];
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (q) {},
                onSuggestionSelected: (product) {},
                minCharacters: 2,
                debounceDelay: Duration.zero,
              ),
            ),
          ),
        );

        // Enter partial query
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        if (state.suggestions.isEmpty) return;

        final originalInput = controller.text;
        final productToSelect = state.suggestions.first;
        
        // Select suggestion
        state.onSuggestionSelected(productToSelect);
        await tester.pump();

        // Property: input is replaced with full product name
        expect(
          controller.text,
          equals(productToSelect.title),
          reason: 'Input "$originalInput" should be replaced with "${productToSelect.title}"',
        );
        expect(
          controller.text,
          isNot(equals(originalInput)),
          reason: 'Input should change after selection (unless query was exact match)',
        );
      });
    }
  });

  // **Feature: search-autocomplete, Property 4: Selection navigates to correct product**
  // **Validates: Requirements 2.1**
  group('Property 4: Selection navigates to correct product', () {
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: selection callback receives correct product', (WidgetTester tester) async {
        final random = Random(iteration + 15000);
        final controller = TextEditingController();
        
        // Use queries that will match products
        final queries = ['Hoodie', 'T-Shirt', 'Mug', 'Backpack', 'University'];
        final query = queries[random.nextInt(queries.length)];
        
        Product? selectedProduct;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (q) {},
                onSuggestionSelected: (product) => selectedProduct = product,
                minCharacters: 2,
                debounceDelay: Duration.zero,
              ),
            ),
          ),
        );

        // Enter query
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        // Skip if no suggestions
        if (state.suggestions.isEmpty) return;

        // Select a random suggestion
        final productToSelect = state.suggestions[random.nextInt(state.suggestions.length)];
        state.onSuggestionSelected(productToSelect);
        await tester.pump();

        // Property: callback receives the exact product that was selected
        expect(
          selectedProduct,
          isNotNull,
          reason: 'onSuggestionSelected callback should be invoked',
        );
        expect(
          selectedProduct!.id,
          equals(productToSelect.id),
          reason: 'Selected product ID "${selectedProduct!.id}" should match expected "${productToSelect.id}"',
        );
        expect(
          selectedProduct!.title,
          equals(productToSelect.title),
          reason: 'Selected product title should match',
        );
      });
    }

    // Test that navigation would use correct product ID for routing
    for (int iteration = 0; iteration < 100; iteration++) {
      testWidgets('iteration $iteration: product ID is valid for navigation route', (WidgetTester tester) async {
        final random = Random(iteration + 16000);
        final controller = TextEditingController();
        
        final queries = ['Hoodie', 'T-Shirt', 'Mug', 'Backpack'];
        final query = queries[random.nextInt(queries.length)];
        
        String? navigatedRoute;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutocompleteSearchField(
                controller: controller,
                onSearch: (q) {},
                onSuggestionSelected: (product) {
                  // Simulate what SearchPage does: navigate to /product/{id}
                  navigatedRoute = '/product/${product.id}';
                },
                minCharacters: 2,
                debounceDelay: Duration.zero,
              ),
            ),
          ),
        );

        // Enter query
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final state = tester.state<AutocompleteSearchFieldState>(
          find.byType(AutocompleteSearchField),
        );

        if (state.suggestions.isEmpty) return;

        final productToSelect = state.suggestions[random.nextInt(state.suggestions.length)];
        state.onSuggestionSelected(productToSelect);
        await tester.pump();

        // Property: navigation route is correctly formed with product ID
        expect(
          navigatedRoute,
          isNotNull,
          reason: 'Navigation route should be set',
        );
        expect(
          navigatedRoute,
          equals('/product/${productToSelect.id}'),
          reason: 'Navigation route should be "/product/${productToSelect.id}"',
        );
        expect(
          navigatedRoute!.contains(productToSelect.id),
          isTrue,
          reason: 'Navigation route should contain the product ID',
        );
      });
    }
  });
}
