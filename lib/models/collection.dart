/// Collection model representing a grouping of related products.
class Collection {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isSaleCollection;

  const Collection({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isSaleCollection = false,
  });

  /// Creates a Collection from a JSON map.
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      isSaleCollection: json['isSaleCollection'] as bool? ?? false,
    );
  }

  /// Converts the Collection to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'isSaleCollection': isSaleCollection,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Collection) return false;
    return id == other.id &&
        title == other.title &&
        description == other.description &&
        imageUrl == other.imageUrl &&
        isSaleCollection == other.isSaleCollection;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, imageUrl, isSaleCollection);
  }
}
