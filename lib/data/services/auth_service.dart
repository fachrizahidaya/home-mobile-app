import 'package:dio/dio.dart';
import '../../ui/core/constants/app_constants.dart';
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
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // After registration, user needs to verify OTP
      if (authResponse.success) {
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

  // Verify OTP (for both registration and login)
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

        // Save user data
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
        // User is verified and authenticated
        if (authResponse.data!['user']['access_token'] != null) {
          await _storageService
              .saveToken(authResponse.data!['user']['access_token']);
          if (authResponse.data != null && authResponse.data!['user'] != null) {
            final user = User.fromJson(authResponse.data!['user']);
            await _storageService.saveUser(user);
          }
        }
      } else if (authResponse.requiresVerification) {
        // User exists but not verified - store email for OTP flow
        await _storageService.saveString(
            'pending_email', authResponse.data!['user']['email']);
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
