import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthState _authState = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthState get authState => _authState;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _authState = AuthState.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  // Register user
  Future<bool> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String username,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        username: username,
      );

      if (response.success) {
        // Registration successful, OTP will be sent
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.verifyOtp(
        email: email,
        otp: otp,
      );

      if (response.success && response.token != null) {
        _user = await _authService.getCurrentUser();
        _authState = AuthState.authenticated;
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<bool> resendOtp(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resendOtp(email);
      if (response.success) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to resend OTP. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success) {
        if (response.requiresOtp == true) {
          // User needs OTP verification
          return true;
        } else if (response.token != null) {
          _user = await _authService.getCurrentUser();
          _authState = AuthState.authenticated;
          return true;
        }
      }

      _setError(response.message);
      return false;
    } catch (e) {
      _setError('Login failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _authState = AuthState.unauthenticated;
    } catch (e) {
      // Handle error
    } finally {
      _setLoading(false);
    }
  }

  // Check username availability
  Future<bool> checkUsernameAvailability(String username) async {
    return await _authService.checkUsernameAvailability(username);
  }

  // Get pending email for OTP verification
  Future<String?> getPendingEmail() async {
    return await _storageService.getString('pending_email');
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
