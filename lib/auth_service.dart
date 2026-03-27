import 'package:homesync/api_client.dart';
import 'package:homesync/api_response.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    return await api.post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<ApiResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await api.post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
  }

  Future<ApiResponse> resendOtp({
    required String email,
  }) async {
    return await api.post('/auth/resend-otp', {
      'email': email,
    });
  }

  Future<ApiResponse> getMe() async {
    return await api.get('/me');
  }

  Future<void> logout() async {
    await api.post('/auth/logout', {});
  }

  Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}
