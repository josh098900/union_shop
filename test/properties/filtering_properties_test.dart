import 'dart:math';
import 'package:test/test.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/models/collection.dart';
import 'package:union_shop/services/filter_service.dart';

/// Helper to create a product with given parameters
Product createProduct({
  required String id,
  required String title,
  required double price,
  required List<String> sizes,
  required List<String> colours,
  required String collectionId,
}) {
  return Product(
    id: id,
    title: title,
    description: 'Description for $title',
    price: price,
    salePrice: null,
    imageUrls: ['https://example.com/image.jpg'],
    sizes: sizes,
    colours: colours,
    collectionId: collectionId,
    createdAt: DateTime.now(),
  );
}

/// Helper to create a collection with given parameters
Collection createCollection({
  required String id,
  required String title,
  required bool isSaleCollection,
}) {
  return Collection(
    id: id,
    title: title,
    description: 'Description for $title',
    imageUrl: 'https://example.com/image.jpg',
    isSaleCollection: isSaleCollection,
  );
}

/// All possible sizes
const allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

/// All possible colours
const allColours = ['Red', 'Blue', 'Green', 'Black', 'White', 'Navy', 'Grey'];

/// All possible collection IDs
const allCollectionIds = ['col-1', 'col-2', 'col-3', 'col-4'];


/// Generates random products with varied attributes for property testing
List<Product> generateRandomProducts(int count, {int seed = 42}) {
  final random = Random(seed);
  final products = <Product>[];
  
  for (int i = 0; i < count; i++) {
    // Random subset of sizes (at least 1)
    final numSizes = 1 + random.nextInt(allSizes.length);
    final sizes = (List<String>.from(allSizes)..shuffle(random)).take(numSizes).toList();
    
    // Random subset of colours (at least 1)
    final numColours = 1 + random.nextInt(allColours.length);
    final colours = (List<String>.from(allColours)..shuffle(random)).take(numColours).toList();
    
    // Random collection
    final collectionId = allCollectionIds[random.nextInt(allCollectionIds.length)];
    
    products.add(createProduct(
      id: 'prod-$i',
      title: 'Product $i',
      price: 10.0 + random.nextDouble() * 190.0,
      sizes: sizes,
      colours: colours,
      collectionId: collectionId,
    ));
  }
  
  return products;
}

/// Generates random collections for property testing
List<Collection> generateRandomCollections(int count, {int seed = 42}) {
  final random = Random(seed);
  final collections = <Collection>[];
  
  for (int i = 0; i < count; i++) {
    collections.add(createCollection(
      id: 'col-$i',
      title: 'Collection $i',
      isSaleCollection: random.nextBool(),
    ));
  }
  
  return collections;
}

void main() {
  final filterService = FilterService();

  group('Filtering Properties', () {
    // **Feature: union-shop-ecommerce, Property 6: Product Filtering Correctness**
    // **Validates: Requirements 12.3**
    group('Property 6: Product Filtering Correctness', () {
      // Test filtering by size
      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(20, seed: iteration);
        final random = Random(iteration);
        final filterSize = allSizes[random.nextInt(allSizes.length)];
        
        test('iteration $iteration: filtering by size "$filterSize" returns only products with that size', () {
          final filter = ProductFilter(size: filterSize);
          final filtered = filterService.filterProducts(products, filter);

          // Verify all filtered products contain the filter size
          for (final product in filtered) {
            expect(
              product.sizes.contains(filterSize),
              isTrue,
              reason: 'Product ${product.id} should contain size $filterSize but has sizes ${product.sizes}',
            );
          }

          // Verify no products with the filter size were excluded
          final expectedCount = products.where((p) => p.sizes.contains(filterSize)).length;
          expect(filtered.length, equals(expectedCount));
        });
      }


      // Test filtering by colour
      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(20, seed: iteration + 100);
        final random = Random(iteration + 100);
        final filterColour = allColours[random.nextInt(allColours.length)];
        
        test('iteration $iteration: filtering by colour "$filterColour" returns only products with that colour', () {
          final filter = ProductFilter(colour: filterColour);
          final filtered = filterService.filterProducts(products, filter);

          // Verify all filtered products contain the filter colour
          for (final product in filtered) {
            expect(
              product.colours.contains(filterColour),
              isTrue,
              reason: 'Product ${product.id} should contain colour $filterColour but has colours ${product.colours}',
            );
          }

          // Verify no products with the filter colour were excluded
          final expectedCount = products.where((p) => p.colours.contains(filterColour)).length;
          expect(filtered.length, equals(expectedCount));
        });
      }

      // Test filtering by collection
      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(20, seed: iteration + 200);
        final random = Random(iteration + 200);
        final filterCollectionId = allCollectionIds[random.nextInt(allCollectionIds.length)];
        
        test('iteration $iteration: filtering by collection "$filterCollectionId" returns only products in that collection', () {
          final filter = ProductFilter(collectionId: filterCollectionId);
          final filtered = filterService.filterProducts(products, filter);

          // Verify all filtered products belong to the filter collection
          for (final product in filtered) {
            expect(
              product.collectionId,
              equals(filterCollectionId),
              reason: 'Product ${product.id} should be in collection $filterCollectionId but is in ${product.collectionId}',
            );
          }

          // Verify no products in the filter collection were excluded
          final expectedCount = products.where((p) => p.collectionId == filterCollectionId).length;
          expect(filtered.length, equals(expectedCount));
        });
      }

      // Test combined filters (size AND colour)
      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(30, seed: iteration + 300);
        final random = Random(iteration + 300);
        final filterSize = allSizes[random.nextInt(allSizes.length)];
        final filterColour = allColours[random.nextInt(allColours.length)];
        
        test('iteration $iteration: filtering by size "$filterSize" AND colour "$filterColour" returns only matching products', () {
          final filter = ProductFilter(size: filterSize, colour: filterColour);
          final filtered = filterService.filterProducts(products, filter);

          // Verify all filtered products match ALL filter criteria
          for (final product in filtered) {
            expect(
              product.sizes.contains(filterSize),
              isTrue,
              reason: 'Product ${product.id} should contain size $filterSize',
            );
            expect(
              product.colours.contains(filterColour),
              isTrue,
              reason: 'Product ${product.id} should contain colour $filterColour',
            );
          }

          // Verify count matches expected
          final expectedCount = products.where((p) => 
            p.sizes.contains(filterSize) && p.colours.contains(filterColour)
          ).length;
          expect(filtered.length, equals(expectedCount));
        });
      }

      // Test empty filter returns all products
      for (int iteration = 0; iteration < 100; iteration++) {
        final products = generateRandomProducts(15, seed: iteration + 400);
        
        test('iteration $iteration: empty filter returns all products', () {
          const filter = ProductFilter();
          final filtered = filterService.filterProducts(products, filter);

          expect(filtered.length, equals(products.length));
        });
      }
    });


    // **Feature: union-shop-ecommerce, Property 4: Collection Filtering Correctness**
    // **Validates: Requirements 11.3**
    group('Property 4: Collection Filtering Correctness', () {
      // Test filtering by sale collection status (true)
      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(15, seed: iteration);
        
        test('iteration $iteration: filtering by isSaleCollection=true returns only sale collections', () {
          const filter = CollectionFilter(isSaleCollection: true);
          final filtered = filterService.filterCollections(collections, filter);

          // Verify all filtered collections are sale collections
          for (final collection in filtered) {
            expect(
              collection.isSaleCollection,
              isTrue,
              reason: 'Collection ${collection.id} should be a sale collection',
            );
          }

          // Verify count matches expected
          final expectedCount = collections.where((c) => c.isSaleCollection).length;
          expect(filtered.length, equals(expectedCount));
        });
      }

      // Test filtering by sale collection status (false)
      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(15, seed: iteration + 100);
        
        test('iteration $iteration: filtering by isSaleCollection=false returns only non-sale collections', () {
          const filter = CollectionFilter(isSaleCollection: false);
          final filtered = filterService.filterCollections(collections, filter);

          // Verify all filtered collections are NOT sale collections
          for (final collection in filtered) {
            expect(
              collection.isSaleCollection,
              isFalse,
              reason: 'Collection ${collection.id} should NOT be a sale collection',
            );
          }

          // Verify count matches expected
          final expectedCount = collections.where((c) => !c.isSaleCollection).length;
          expect(filtered.length, equals(expectedCount));
        });
      }

      // Test empty filter returns all collections
      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(15, seed: iteration + 200);
        
        test('iteration $iteration: empty filter returns all collections', () {
          const filter = CollectionFilter();
          final filtered = filterService.filterCollections(collections, filter);

          expect(filtered.length, equals(collections.length));
        });
      }

      // Test filtering does not modify original list
      for (int iteration = 0; iteration < 100; iteration++) {
        final collections = generateRandomCollections(15, seed: iteration + 300);
        
        test('iteration $iteration: filtering does not modify the original list', () {
          final originalIds = collections.map((c) => c.id).toList();

          const filter = CollectionFilter(isSaleCollection: true);
          filterService.filterCollections(collections, filter);

          // Verify original list is unchanged
          final currentIds = collections.map((c) => c.id).toList();
          expect(currentIds, equals(originalIds));
        });
      }
    });
  });
}
