import 'dart:math';
import 'package:test/test.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/services/search_service.dart';
import 'package:union_shop/services/product_service.dart';

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

/// Sample words for generating random product titles and descriptions
const sampleTitleWords = [
  'University', 'Portsmouth', 'Campus', 'Student', 'Varsity',
  'Classic', 'Premium', 'Official', 'Limited', 'Special',
];

const sampleProductTypes = [
  'Hoodie', 'T-Shirt', 'Jacket', 'Sweatshirt', 'Beanie',
  'Scarf', 'Backpack', 'Mug', 'Notebook', 'Pen',
];

const sampleDescriptionWords = [
  'comfortable', 'stylish', 'durable', 'soft', 'warm',
  'lightweight', 'premium', 'quality', 'branded', 'official',
  'cotton', 'polyester', 'embroidered', 'printed', 'logo',
];

/// Generates a random product title
String generateRandomTitle(Random random) {
  final adjective = sampleTitleWords[random.nextInt(sampleTitleWords.length)];
  final product = sampleProductTypes[random.nextInt(sampleProductTypes.length)];
  return '$adjective $product';
}

/// Generates a random product description
String generateRandomDescription(Random random) {
  final words = <String>[];
  final numWords = 5 + random.nextInt(10);
  for (int i = 0; i < numWords; i++) {
    words.add(sampleDescriptionWords[random.nextInt(sampleDescriptionWords.length)]);
  }
  return words.join(' ');
}


/// Generates random products for property testing
List<Product> generateRandomProducts(int count, {int seed = 42}) {
  final random = Random(seed);
  final products = <Product>[];
  
  for (int i = 0; i < count; i++) {
    products.add(createProduct(
      id: 'prod-$i',
      title: generateRandomTitle(random),
      description: generateRandomDescription(random),
      price: 10.0 + random.nextDouble() * 90.0,
    ));
  }
  
  return products;
}

/// Generates a random search query from existing product data
String generateSearchQuery(List<Product> products, Random random) {
  // Pick a random product
  final product = products[random.nextInt(products.length)];
  
  // Decide whether to search by title or description
  if (random.nextBool()) {
    // Extract a word from the title
    final titleWords = product.title.split(' ');
    return titleWords[random.nextInt(titleWords.length)];
  } else {
    // Extract a word from the description
    final descWords = product.description.split(' ');
    return descWords[random.nextInt(descWords.length)];
  }
}

void main() {
  group('Search Properties', () {
    // **Feature: union-shop-ecommerce, Property 15: Search Results Relevance**
    // **Validates: Requirements 19.3**
    group('Property 15: Search Results Relevance', () {
      
      // Test that all search results contain the query in title or description
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: all search results contain the query (case-insensitive)', () {
          // Use the actual ProductService which has real product data
          final searchService = SearchService(productService: ProductService());
          final allProducts = ProductService().getAll();
          
          // Generate a search query from existing product data
          final random = Random(iteration);
          final query = generateSearchQuery(allProducts, random);
          
          // Perform search
          final results = searchService.search(query);
          final lowerQuery = query.toLowerCase();
          
          // Verify all results contain the query in title or description
          for (final product in results) {
            final titleContains = product.title.toLowerCase().contains(lowerQuery);
            final descContains = product.description.toLowerCase().contains(lowerQuery);
            
            expect(
              titleContains || descContains,
              isTrue,
              reason: 'Product "${product.title}" should contain "$query" in title or description',
            );
          }
        });
      }

      // Test that search is case-insensitive
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: search is case-insensitive', () {
          final searchService = SearchService(productService: ProductService());
          final allProducts = ProductService().getAll();
          
          final random = Random(iteration + 1000);
          final query = generateSearchQuery(allProducts, random);
          
          // Search with different cases
          final lowerResults = searchService.search(query.toLowerCase());
          final upperResults = searchService.search(query.toUpperCase());
          final mixedResults = searchService.search(query);
          
          // All should return the same results
          expect(
            lowerResults.map((p) => p.id).toSet(),
            equals(upperResults.map((p) => p.id).toSet()),
            reason: 'Lower and upper case searches should return same results',
          );
          expect(
            lowerResults.map((p) => p.id).toSet(),
            equals(mixedResults.map((p) => p.id).toSet()),
            reason: 'Mixed case search should return same results',
          );
        });
      }

      // Test that empty query returns empty results
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: empty or whitespace query returns empty results', () {
          final searchService = SearchService(productService: ProductService());
          
          // Test various empty/whitespace queries
          final emptyQueries = ['', ' ', '  ', '\t', '\n', '   '];
          final random = Random(iteration + 2000);
          final query = emptyQueries[random.nextInt(emptyQueries.length)];
          
          final results = searchService.search(query);
          
          expect(
            results.isEmpty,
            isTrue,
            reason: 'Empty or whitespace query should return empty results',
          );
        });
      }

      // Test that no matching products are excluded
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: no matching products are excluded from results', () {
          final productService = ProductService();
          final searchService = SearchService(productService: productService);
          final allProducts = productService.getAll();
          
          final random = Random(iteration + 3000);
          final query = generateSearchQuery(allProducts, random);
          final lowerQuery = query.toLowerCase();
          
          // Perform search
          final results = searchService.search(query);
          final resultIds = results.map((p) => p.id).toSet();
          
          // Find all products that should match
          final expectedMatches = allProducts.where((p) =>
            p.title.toLowerCase().contains(lowerQuery) ||
            p.description.toLowerCase().contains(lowerQuery)
          ).toList();
          
          // Verify all expected matches are in results
          for (final expected in expectedMatches) {
            expect(
              resultIds.contains(expected.id),
              isTrue,
              reason: 'Product "${expected.title}" should be in search results for "$query"',
            );
          }
          
          // Verify counts match
          expect(
            results.length,
            equals(expectedMatches.length),
            reason: 'Search results count should match expected matches',
          );
        });
      }

      // Test productMatchesQuery helper method
      for (int iteration = 0; iteration < 100; iteration++) {
        test('iteration $iteration: productMatchesQuery returns correct boolean', () {
          final searchService = SearchService(productService: ProductService());
          final allProducts = ProductService().getAll();
          
          final random = Random(iteration + 4000);
          final product = allProducts[random.nextInt(allProducts.length)];
          final query = generateSearchQuery(allProducts, random);
          final lowerQuery = query.toLowerCase();
          
          final matches = searchService.productMatchesQuery(product, query);
          final expectedMatch = product.title.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery);
          
          expect(
            matches,
            equals(expectedMatch),
            reason: 'productMatchesQuery should return $expectedMatch for "${product.title}" with query "$query"',
          );
        });
      }
    });
  });
}
