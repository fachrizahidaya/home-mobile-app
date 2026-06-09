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
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : null;

    final user = data?['user'];
    final userMap = user is Map<String, dynamic>
        ? user
        : user is Map
            ? Map<String, dynamic>.from(user)
            : null;

    final token = json['token'] ??
        data?['token'] ??
        data?['access_token'] ??
        userMap?['access_token'];

    final success = json['success'] == true;

    final message = json['message'] ?? json['msg'] ?? '';

    final requiresVerification = json['requires_verification'] == true ||
        json['requiresVerification'] == true ||
        json['requires_otp'] == true ||
        json['requiresOtp'] == true;

    final email = json['email'] ?? data?['email'] ?? userMap?['email'];

    return AuthResponse(
      success: success,
      message: message,
      data: data,
      token: token?.toString(),
      email: email?.toString(),
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
