class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? data;
  final String? email;
  final bool requiresVerification;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.data,
    this.email,
    this.requiresVerification = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    final token = data?['access_token'];

    final success = json['success'];

    final message = json['message'] ?? json['msg'] ?? '';

    final requiresVerification =
        json['requires_verification'] ?? json['requiresVerification'] ?? false;

    return AuthResponse(
      success: success,
      message: message,
      data: data,
      token: token,
      requiresVerification: requiresVerification,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'data': data,
      'email': data?['user']?['email'] ?? email,
      'requires_verification': requiresVerification,
    };
  }
}
