class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? data;
  final bool? requiresOtp;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.data,
    this.requiresOtp,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: json['token'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      requiresOtp: json['requires_otp'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'data': data,
      'requires_otp': requiresOtp,
    };
  }
}
