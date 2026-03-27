class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final bool? requiresVerification;
  final String? email;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.requiresVerification,
    this.email,
  });
}
