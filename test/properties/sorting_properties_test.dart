import 'dart:math';
import 'package:test/test.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/models/collection.dart';
import 'package:union_shop/services/filter_service.dart';
import 'package:union_shop/widgets/sort_dropdown.dart';

/// Helper to create a product with given parameters
Product createProduct({
  required String id,
  required String title,
  required double price,
  double? salePrice,
  required DateTime createdAt,
}) {
  return Product(
    id: id,
    title: title,
    description: 'Description for $title',
    price: price,
    salePrice: salePrice,
    imageUrls: ['https://example.com/image.jpg'],
    sizes: ['S', 'M', 'L'],
    colours: ['Red', 'Blue'],
    collectionId: 'col-1',
    createdAt: createdAt,
  );
}

/// Helper to create a collection with given parameters
Collection createCollection({
  required String id,
  required String title,
}) {
  return Collection(
    id: id,
    title: title,
    description: 'Description for $title',
    imageUrl: 'https://example.com/image.jpg',
    isSaleCollection: false,
  );
}

/// Generates random products for property testing
List<Product> generateRandomProducts(int count, {int seed = 42}) {
  final random = Random(seed);
  final products = <Product>[];
  
  final titles = [
    'Alpha Hoodie', 'Beta Shirt', 'Gamma Cap', 'Delta Jacket',
    'Epsilon Bag', 'Zeta Bottle', 'Eta Notebook', 'Theta Polo',
    'Iota Beanie', 'Kappa Scarf', 'Lambda Gloves', 'Mu Socks',
  ];

  for (int i = 0; i < count; i++) {
    final title = titles[random.nextInt(titles.length)] + ' ${random.nextInt(1000)}';
    final price = 5.0 + random.nextDouble() * 195.0;
    final hasSale = random.nextBool();
    final salePrice = hasSale ? price * (0.5 + random.nextDouble() * 0.4) : null;
    final daysAgo = random.nextInt(365);
    
    products.add(createProduct(
      id: 'prod-$i',
      title: title,
      price: price,
      salePrice: salePrice != null && salePrice < price ? salePrice : null,
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
    ));
  }
  
  return products;
}

/// Generates random collections for property testing
List<Collection> generateRandomCollections(int count, {int seed = 42}) {
  final random = Random(seed);
  final collections = <Collection>[];
  
  final titles = [
    'Summer Collection', 'Winter Essentials', 'Spring Fashion',
    'Autumn Styles', 'Sports Gear', 'Casual Wear', 'Formal Attire',
    'Accessories', 'Limited Edition', 'New Arrivals', 'Best Sellers',
  ];
  
  for (int i = 0; i < count; i++) {
    final title = titles[random.nextInt(titles.length)] + ' ${random.nextInt(1000)}';
    collections.add(createCollection(
      id: 'col-$i',
      title: title,
    ));
  }
  
  return collections;
}

void main() {
  final filterService = FilterService();

  group('Sorting Properties', () {
    // **Feature: union-shop-ecommerce, Property 5: Product Sorting Correctness**
    // **Validates: Requirements 12.2**
    group('Property 5: Product Sorting Correctness', () {
      // Run 100 iterations with different seeds
      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(10, seed: iteration);
        
        test('iteration $iteration: sorting by price ascending orders products from lowest to highest price', () {
          final sorted = filterService.sortProducts(products, SortOption.priceAsc);

          // Verify the list is sorted by displayPrice ascending
          for (int i = 0; i < sorted.length - 1; i++) {
            expect(
              sorted[i].displayPrice <= sorted[i + 1].displayPrice,
              isTrue,
              reason: 'Product at index $i (${sorted[i].displayPrice}) should be <= product at index ${i + 1} (${sorted[i + 1].displayPrice})',
            );
          }
        });
      }


      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(10, seed: iteration + 100);
        
        test('iteration $iteration: sorting by price descending orders products from highest to lowest price', () {
          final sorted = filterService.sortProducts(products, SortOption.priceDesc);

          // Verify the list is sorted by displayPrice descending
          for (int i = 0; i < sorted.length - 1; i++) {
            expect(
              sorted[i].displayPrice >= sorted[i + 1].displayPrice,
              isTrue,
              reason: 'Product at index $i (${sorted[i].displayPrice}) should be >= product at index ${i + 1} (${sorted[i + 1].displayPrice})',
            );
          }
        });
      }

      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(10, seed: iteration + 200);
        
        test('iteration $iteration: sorting by newest orders products from most recent to oldest', () {
          final sorted = filterService.sortProducts(products, SortOption.newest);

          // Verify the list is sorted by createdAt descending (newest first)
          for (int i = 0; i < sorted.length - 1; i++) {
            expect(
              sorted[i].createdAt.compareTo(sorted[i + 1].createdAt) >= 0,
              isTrue,
              reason: 'Product at index $i (${sorted[i].createdAt}) should be >= product at index ${i + 1} (${sorted[i + 1].createdAt})',
            );
          }
        });
      }

      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(10, seed: iteration + 300);
        
        test('iteration $iteration: sorting by name ascending orders products alphabetically A-Z', () {
          final sorted = filterService.sortProducts(products, SortOption.nameAsc);

          // Verify the list is sorted alphabetically by title (case-insensitive)
          for (int i = 0; i < sorted.length - 1; i++) {
            final comparison = sorted[i].title.toLowerCase().compareTo(
                  sorted[i + 1].title.toLowerCase(),
                );
            expect(
              comparison <= 0,
              isTrue,
              reason: 'Product at index $i (${sorted[i].title}) should be <= product at index ${i + 1} (${sorted[i + 1].title})',
            );
          }
        });
      }

      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(10, seed: iteration + 400);
        
        test('iteration $iteration: sorting preserves all original products', () {
          for (final sortOption in SortOption.values) {
            final sorted = filterService.sortProducts(products, sortOption);

            // Verify same length
            expect(sorted.length, equals(products.length));

            // Verify all original products are present
            for (final product in products) {
              expect(sorted.contains(product), isTrue);
            }
          }
        });
      }
    });


    // **Feature: union-shop-ecommerce, Property 3: Collection Sorting Correctness**
    // **Validates: Requirements 11.2**
    group('Property 3: Collection Sorting Correctness', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(10, seed: iteration);
        
        test('iteration $iteration: sorting by name ascending orders collections alphabetically A-Z', () {
          final sorted = filterService.sortCollections(collections, SortOption.nameAsc);

          // Verify the list is sorted alphabetically by title (case-insensitive)
          for (int i = 0; i < sorted.length - 1; i++) {
            final comparison = sorted[i].title.toLowerCase().compareTo(
                  sorted[i + 1].title.toLowerCase(),
                );
            expect(
              comparison <= 0,
              isTrue,
              reason: 'Collection at index $i (${sorted[i].title}) should be <= collection at index ${i + 1} (${sorted[i + 1].title})',
            );
          }
        });
      }

      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(10, seed: iteration + 100);
        
        test('iteration $iteration: sorting preserves all original collections', () {
          for (final sortOption in SortOption.values) {
            final sorted = filterService.sortCollections(collections, sortOption);

            // Verify same length
            expect(sorted.length, equals(collections.length));

            // Verify all original collections are present
            for (final collection in collections) {
              expect(sorted.contains(collection), isTrue);
            }
          }
        });
      }

      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(10, seed: iteration + 200);
        
        test('iteration $iteration: sorting does not modify the original list', () {
          final originalIds = collections.map((c) => c.id).toList();

          for (final sortOption in SortOption.values) {
            filterService.sortCollections(collections, sortOption);

            // Verify original list is unchanged
            final currentIds = collections.map((c) => c.id).toList();
            expect(currentIds, equals(originalIds));
          }
        });
      }
    });
  });
}
