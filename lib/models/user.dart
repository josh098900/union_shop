/// User model representing an authenticated user.
class User {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  /// Creates a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts the User to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this User with the given fields replaced.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! User) return false;
    return id == other.id &&
        email == other.email &&
        displayName == other.displayName &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, displayName, createdAt);
  }
}
