import 'package:flutter/material.dart';
import '../models/collection.dart';

/// A card widget that displays a collection preview in grid layouts.
///
/// Displays collection image and title. Tapping the card navigates
/// to the collection's product listing page.
///
/// Requirements: 5.2, 5.3
class CollectionCard extends StatelessWidget {
  /// The collection to display
  final Collection collection;

  /// Optional callback when the card is tapped
  /// If not provided, navigates to /collection/{id}
  final VoidCallback? onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToCollection(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collection image (Req 5.2)
            _buildImageSection(),
            // Collection title (Req 5.2)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                collection.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the collection page (Req 5.3)
  void _navigateToCollection(BuildContext context) {
    Navigator.pushNamed(context, '/collection/${collection.id}');
  }

  /// Builds the image section
  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _buildCollectionImage(),
    );
  }

  /// Builds the collection image with error handling
  Widget _buildCollectionImage() {
    if (collection.imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.network(
      collection.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  /// Builds a placeholder image when no image is available
  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.collections,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}
