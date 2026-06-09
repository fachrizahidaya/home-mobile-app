import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/data/models/auth_response.dart';

void main() {
  test('AuthResponse parses login token and verification flags', () {
    final loginResponse = AuthResponse.fromJson({
      'success': true,
      'message': 'Login successful',
      'token': 'plain-token',
      'data': {
        'user': {
          'id': 1,
          'name': 'Home User',
          'username': 'homeuser',
          'email': 'home@example.com',
          'role': 'member',
        },
      },
    });

    expect(loginResponse.success, isTrue);
    expect(loginResponse.token, 'plain-token');
    expect(loginResponse.requiresVerification, isFalse);

    final verificationResponse = AuthResponse.fromJson({
      'success': true,
      'message': 'Please verify your email',
      'requires_otp': true,
      'email': 'home@example.com',
    });

    expect(verificationResponse.requiresVerification, isTrue);
    expect(verificationResponse.email, 'home@example.com');
  });
}
