import 'dart:convert';
import 'package:homesync/api_response.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiClient {
  final String baseUrl;
  final StorageService storage;

  ApiClient({
    required this.baseUrl,
    required this.storage,
  });

  Future<Map<String, String>> _headers() async {
    final token = await storage.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  ApiResponse _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    return ApiResponse(
      success: data['success'] ?? false,
      message: data['message'] ?? '',
      data: data['data'],
      requiresVerification: data['requires_verification'],
      email: data['email'],
    );
  }
}
