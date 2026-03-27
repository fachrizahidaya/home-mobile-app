import 'package:flutter/foundation.dart';
import 'package:homesync/core/constants/app_constants.dart';
import 'package:homesync/data/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';

enum AuthState {
  initial,
  authenticated,
  needsVerification,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthState _authState = AuthState.initial;
  User? _user;
  String? _errorMessage;
  String? _pendingEmail;
  bool _isLoading = false;

  AuthState get authState => _authState;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get pendingEmail => _pendingEmail;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get needsVerification => _authState == AuthState.needsVerification;

  // Initialize auth state on app startup
  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        _user = await _storageService.getUser();
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

  // ============ REGISTER ============
  Future<bool> register({
    required String email,
    required String password,
    required String passwordConfirmation,
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
      );

      if (response.success) {
        _pendingEmail = email;
        _authState = AuthState.needsVerification;
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

  // ============ LOGIN ============
  Future<LoginResult> login({
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
        // User is verified and authenticated
        _user = response.data!['user'] != null
            ? User.fromJson(response.data!['user'])
            : null;
        _authState = AuthState.authenticated;
        return LoginResult(
            success: true, message: response.message, needsVerification: false);
      } else if (response.requiresVerification) {
        // User not verified - needs OTP
        _pendingEmail = email;
        _authState = AuthState.needsVerification;
        return LoginResult(
          success: false,
          needsVerification: true,
          message: response.message,
        );
      } else {
        _setError(response.message);
        return LoginResult(
            success: false,
            message: response.message,
            needsVerification: false);
      }
    } catch (e) {
      final errorMsg = 'Login failed. Please try again.';
      _setError(errorMsg);
      return LoginResult(success: false, message: errorMsg);
    } finally {
      _setLoading(false);
    }
  }

  // ============ OTP VERIFICATION ============
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
        _user = response.data?['user'] != null
            ? User.fromJson(response.data!['user'])
            : null;
        _pendingEmail = null;
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

  // ============ RESEND OTP ============
  Future<bool> resendOtp() async {
    if (_pendingEmail == null) {
      _setError('Email not found. Please try again.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resendOtp(_pendingEmail!);
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

  // ============ LOGOUT ============
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.post(AppConstants.logoutEndpoint);
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.clearAll();
      _user = null;
      _pendingEmail = null;
      _authState = AuthState.unauthenticated;
      _setLoading(false);
    }
  }

  // ============ CHECK USERNAME AVAILABILITY ============
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      return await _authService.checkUsernameAvailability(username);
    } catch (e) {
      return false;
    }
  }

  // ============ HELPER METHODS ============
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

// Helper class for login result
class LoginResult {
  final bool success;
  final bool needsVerification;
  final String? message;

  LoginResult({
    required this.success,
    this.needsVerification = false,
    this.message,
  });
}
