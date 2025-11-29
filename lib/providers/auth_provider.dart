import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state across the application.
///
/// Extends ChangeNotifier to notify listeners when auth state changes.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// The currently logged-in user, or null if not logged in.
  User? get user => _user;

  /// Whether an auth operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The last error message, if any.
  String? get error => _error;

  /// Whether a user is currently logged in.
  bool get isLoggedIn => _user != null;

  /// Initializes the auth state by checking for a stored user session.
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _error = 'Failed to initialize auth';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new user with the provided credentials.
  ///
  /// Returns true if registration was successful.
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result.success) {
        _user = result.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs in a user with the provided credentials.
  ///
  /// Returns true if login was successful.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success) {
        _user = result.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs out the current user.
  ///
  /// Returns true if logout was successful.
  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.logout();
      if (success) {
        _user = null;
      } else {
        _error = 'Logout failed';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
