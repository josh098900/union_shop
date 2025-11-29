import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Result of an authentication operation.
class AuthResult {
  final bool success;
  final User? user;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
  });

  const AuthResult.success(User user)
      : success = true,
        user = user,
        errorMessage = null;

  const AuthResult.failure(String message)
      : success = false,
        user = null,
        errorMessage = message;
}

/// Service for managing user authentication with local storage persistence.
///
/// Provides methods to register, login, logout, and get the current user.
class AuthService {
  static const String _currentUserKey = 'union_shop_current_user';
  static const String _usersKey = 'union_shop_users';

  /// Registers a new user with the provided email and password.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return const AuthResult.failure('Invalid email format');
      }

      // Validate password
      if (password.length < 6) {
        return const AuthResult.failure(
            'Password must be at least 6 characters');
      }

      final prefs = await SharedPreferences.getInstance();

      // Check if user already exists
      final users = await _getUsers(prefs);
      if (users.containsKey(email)) {
        return const AuthResult.failure('Email already registered');
      }

      // Create new user
      final user = User(
        id: _generateUserId(),
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      // Store user with password hash (simple hash for demo purposes)
      users[email] = {
        'user': user.toJson(),
        'passwordHash': _hashPassword(password),
      };

      await _saveUsers(prefs, users);

      // Set as current user
      await _setCurrentUser(prefs, user);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  /// Logs in a user with the provided email and password.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return const AuthResult.failure('Invalid email format');
      }

      final prefs = await SharedPreferences.getInstance();

      // Get stored users
      final users = await _getUsers(prefs);

      // Check if user exists
      if (!users.containsKey(email)) {
        return const AuthResult.failure('Email not found');
      }

      final userData = users[email]!;
      final storedHash = userData['passwordHash'] as String;

      // Verify password
      if (_hashPassword(password) != storedHash) {
        return const AuthResult.failure('Incorrect password');
      }

      // Get user and set as current
      final user = User.fromJson(userData['user'] as Map<String, dynamic>);
      await _setCurrentUser(prefs, user);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  /// Logs out the current user.
  ///
  /// Returns true if logout was successful.
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_currentUserKey);
    } catch (e) {
      return false;
    }
  }

  /// Gets the currently logged-in user.
  ///
  /// Returns null if no user is logged in.
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson == null || userJson.isEmpty) {
        return null;
      }

      final json = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Private helper methods

  Future<Map<String, dynamic>> _getUsers(SharedPreferences prefs) async {
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      return {};
    }
    return Map<String, dynamic>.from(jsonDecode(usersJson) as Map);
  }

  Future<bool> _saveUsers(
      SharedPreferences prefs, Map<String, dynamic> users) async {
    return await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<bool> _setCurrentUser(SharedPreferences prefs, User user) async {
    return await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String _hashPassword(String password) {
    // Simple hash for demo purposes - in production use bcrypt or similar
    var hash = 0;
    for (var i = 0; i < password.length; i++) {
      hash = ((hash << 5) - hash) + password.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  String _generateUserId() {
    return 'user-${DateTime.now().millisecondsSinceEpoch}';
  }
}
