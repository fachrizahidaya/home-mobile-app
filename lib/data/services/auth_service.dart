import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String username,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'username': username,
          'role': 'member',
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // If registration successful and requires OTP
      if (authResponse.success && authResponse.requiresOtp == true) {
        // Store email temporarily for OTP verification
        await _storageService.saveString('pending_email', email);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
        success: false,
        message: _apiService.getErrorMessage(e),
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Verify OTP
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.verifyOtpEndpoint,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.token != null) {
        // Save token
        await _storageService.saveToken(authResponse.token!);

        // Save user data if available
        if (authResponse.data != null && authResponse.data!['user'] != null) {
          final user = User.fromJson(authResponse.data!['user']);
          await _storageService.saveUser(user);
        }

        // Clear pending email
        await _storageService.remove('pending_email');
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
        success: false,
        message: _apiService.getErrorMessage(e),
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Resend OTP
  Future<AuthResponse> resendOtp(String email) async {
    try {
      final response = await _apiService.post(
        AppConstants.resendOtpEndpoint,
        data: {'email': email},
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
        success: false,
        message: _apiService.getErrorMessage(e),
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success) {
        if (authResponse.requiresOtp == true) {
          // User needs to verify OTP
          await _storageService.saveString('pending_email', email);
        } else if (authResponse.token != null) {
          // Login successful with token
          await _storageService.saveToken(authResponse.token!);
          await _storageService.saveToken(authResponse.token!);

          if (authResponse.data != null && authResponse.data!['user'] != null) {
            final user = User.fromJson(authResponse.data!['user']);
            await _storageService.saveUser(user);
          }
        }
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
        success: false,
        message: _apiService.getErrorMessage(e),
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(AppConstants.logoutEndpoint);
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.clearAll();
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null;
  }

  // Check username availability
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await _apiService.post(
        '/auth/check-username',
        data: {'username': username},
      );

      return response.data['available'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
